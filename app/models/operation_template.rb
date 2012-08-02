# coding: utf-8

# 操作模板，所有的运维操作都基于一个模型来执行，大部分原子指令也是在 gen_operation 的时候生成的
class OperationTemplate < ActiveRecord::Base

  belongs_to :app
  has_many   :operations
  has_many   :restrictions, :class_name => 'OperationRestriction' do
    def [] env_obj
      if env_obj.is_a? Fixnum
        super
      else
        where(:env_id => env_obj.id).first
      end
    end
  end

  attr_accessor :source_ids
  attr_accessor :restriction_obj # hash 对象，格式为 { env_id => limit , ... }

  validates_length_of :source_ids,:minimum => 1,:message => "至少需要选择一个"
  
  validates_uniqueness_of :name, :scope => [:app_id]
  
  validates_presence_of :name

  before_save :set_source_ids
  after_save :update_restrictions
  
  def set_source_ids
    self.expression   = self.source_ids.join "," if self.source_ids
  end
  
  def update_restrictions
    return if self.restriction_obj.nil?
    raise '限制数不能小于0' if self.restriction_obj.values.map(&:to_i).min < 0
    self.restriction_obj.each do |key,value|
      env = self.app.envs[key]
      restriction = self.restrictions[env]
      if restriction.nil?
        self.restrictions.create(
          env_id: env.id,
          limit: value.to_i, 
          limit_cycle: 'W'
        )
      else
        restriction.limit = value.to_i
        restriction.save # 当对象没有修改时 save 会自动忽略
      end
    end
  end
  # 根据本 operation_template 创建一个操作
  # choosed_machine_ids: 操作所对应的机器
  # previous_id: 上次操作的操作id，用于建立链式操作过程
  # is_hold: 操作创建时的状态，有效值包括true，false，nil，分别对应hold，wait和init
  def gen_operation user, choosed_machine_ids,previous_id=nil, is_hold=nil
    machine_ids = available_machines(user).collect{|m| m.id} & choosed_machine_ids
    raise '您选择的机器不允许执行相关操作，请在操作允许的机器中进行选择' if machine_ids.size == 0

    check_operation_limitation machine_ids
    #支持operation_template进行前处理，self是当前operation_template
    if self.begin_script and previous_id.nil?
      instance_eval(begin_script) 
    end
    
    state = case is_hold
              when true
                'hold'
              when false
                'wait'
              when nil
                'init'
            end
    operation = operations.create(
        :operator => user, :name => name, :app => app,:previous_id => previous_id,:state => state
    )
    
    build_machine_operations operation.id, machine_ids
    build_directives operation.id, machine_ids, state != 'init'
    
    operation
  end

  def gen_operation_by_group user,group_count,is_hold
    all_ids = available_machines( user ).collect{|m| m.id}

    previous_id = nil
    make_groups( all_ids, group_count ).
      collect do |a_group_ids|
        operation_on_bottom = gen_operation(user, a_group_ids, previous_id,is_hold)
        previous_id = operation_on_bottom.id
        operation_on_bottom
      end.
      tap{|operations| operations.first.enable}
  end

  def check_operation_limitation machine_ids
    limit_map = Hash[self.restrictions.map{|o| [o.env_id, o.limit]}]
    MachineOperation.
      where(operation_template_id: self.id).count(:group => 'machine_id').
      each do |machine_id,count|
        machine = Machine.where(id:machine_id).first
        next if machine.nil? || machine.env_id.nil?
        limit = limit_map[machine.env_id]
        if limit && limit > 0
          if count >= limit
            raise '操作次数超过限制'
          end
        end
      end
  end

  def make_groups arr, group_count
    group_length = (arr.size.to_f / group_count.to_f).ceil
    arr.in_groups_of(group_length)
  end

  # 生成相应的machine operation记录
  def build_machine_operations operation_id, machine_ids
    machine_ids.each do |m_id| 
      MachineOperation.create(
        machine_id: m_id, operation_id: operation_id, operation_template_id: self.id
      )
    end
  end

  # 根据 operation id 生成 directive 记录)
  # machine_ids 要求必须是一个integer数组
  def build_directives operation_id, machine_ids, is_hold
    if machine_ids
      machines = app.machines.where(:id => machine_ids[0..10])
    else
      machines = app.machines
    end
    room_map = Room.
        where(:id => machines.collect { |m| m.room_id }.uniq).
        inject({}) { |map, room| map.update(room.id => room.name) }

    properties = Property.global.pairs
    properties.update( app.properties.pairs )
    directive_templates do |directive_template, next_when_fail|
      # 循环创建 directive 对象
      machines.collect { |m|
        command_name = directive_template.name
        directive_template_id = directive_template.id
        properties.update(m.env.properties.pairs) if m.env

        m.directives.create(
            :directive_template_id => directive_template_id,
            :operation_id => operation_id,
            :room_id => m.room_id,
            :machine_host => m.host,
            :command_name => command_name,
            :room_name => room_map[m.room_id],
            :params => properties,
            :next_when_fail => next_when_fail,
            :state => is_hold ? 'hold' : 'init'
        )
      }
    end
  end
  
  def available_machines user
    user.owned_machines(app,self.id)
  end

  def directive_templates
    pairs = (expression||"").strip.split(',').collect{ |item|
      k,v = item.squish.split('|')
      [k.to_i, v]
    }

    templates = DirectiveTemplate.
      where(:id => pairs.map{|pair| pair[0]}.uniq).
      all.
      inject({}) do |map, m|
        map.update( m.id => m)
      end
    if block_given?
      pairs.each do |pair|
        if templates[pair[0]]
          yield templates[pair[0]], pair[1] == "true" # 为真表示错误可忽略
        end
      end
    end
  end

end
