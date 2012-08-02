# coding: utf-8

# 在一台机器上运行的一个原子指令实例，指令本身的生命周期用state_machine进行了约定
# 大部分原子指令从属于一个操作，某些特殊的原子指令独立运行，此时 operation_id 为
# operation模型指定的缺省值
#
class Directive < ActiveRecord::Base
  belongs_to :machine
  belongs_to :operation
  belongs_to :template, :class_name => 'DirectiveTemplate', :foreign_key => 'directive_template_id'
  
  scope :asc, order("operation_id asc, id asc")

  scope :desc, order("id desc")

  scope :normal, where('operation_id <> 0')
  
  attr_accessor :params

  before_create do
    if params && params.is_a?(Hash)
      params.each_pair do |k,v|
        command_name.gsub! %r{\$#{k}}, "#{v}"
      end
    end
  end

  # 反馈执行结果
  def callback( isok, body)
    self.isok = isok
    self.response = body.valid_encoding? ? body : encode_try(body)
    isok ? ok : error
  end

  state_machine :state, :initial => :init do
    # 需要延迟使用的directive，可以初始化为hold状态
    event :enable do transition :hold => :init end
    # 清理已经无用的未执行directive
    event :clear do transition [:disable, :init, :ready] => :done end
    event :download do transition :init => :ready end
    event :invoke do transition :ready => :running end
    event :force_stop do transition :running => :failure end
    event :error do transition [:init,:running] => :failure end
    event :ok do transition [:ready, :running] => :done end
    event :ack do transition :failure => :done end

    after_transition :on => :invoke, :do => :fire_operation
    after_transition :on => :error, :do => :error_fire
    after_transition :on => [:ok,:ack], :do => :try_operation_done
    after_transition :on => [:clear], :do => :try_operation_clear
    before_transition :on => [:clear,:force_stop], :do => :put_response
  end
  
  def events_for_user
    state_events - [:download,:error,:invoke,:ok,:force_stop,:clear,:enable]
  end

  def put_response
    self.response = "stoped( when #{self.state})"
  end

  def fire_operation
    operation.fire if has_operation?
  end

  def error_fire
    operation.error if has_operation?
    machine.pause if machine
  end
  
  def try_operation_done
    if has_operation? and operation.directives.without_state(:done).count == 0
      operation.ok || operation.ack
    end
  end

  def try_operation_clear
    operation.error if has_operation?
  end

  # 独立指令没有对应的操作对象，此时 operation_id 为0
  def has_operation?
    operation_id != Operation::DEFAULT_ID
  end

  def control?
    (self.command_name||'').start_with? 'machine|'
  end
  
  def encode_try text
    ['GBK'].each do |from_enc|
      result = text.encode 'utf-8', from_enc
      return result if result.valid_encoding?
    end
    'Agent错误[编码不支持]'
  end
end
