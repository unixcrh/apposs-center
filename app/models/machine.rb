# coding: utf-8
class Machine < ActiveRecord::Base

  default_scope where("`machines`.`state` <> 'offlined' and `machines`.`state` <> 'offlined'").order(:name)
  
  belongs_to :room
  belongs_to :env
  belongs_to :app

  has_many :machine_operations
  has_many :directives

  validates_inclusion_of :port,:in => 1..65535,:message => "port必须在1到65535之间"
  validates_presence_of :name

  before_create :fulfill_default

  def fulfill_default
    if self.host.nil? or self.host.empty?
      self.host = self.name
    end
  end

  state_machine :state, :initial => :normal do
    event :pause do transition all => :paused end
    event :reset do transition all => :normal end
    event :disconnect do transition all => :disconnected end
    event :offline do transition all => :offlined end
  end

  def reassign app_id
    return false if (app && app.locked?) #允许尚未分配app的machine进行重新设置
    app = App.find app_id
    transaction do
      self.directives.each do |dd|
        dd.update_attribute :operation_id, Operation::DEFAULT_ID
      end
      self.update_attribute(:app_id, app.id)
      self.update_attribute(:env_id, app.envs[(self.env.try(:name)||'online').to_sym,true].id)
    end
  end

  def send_pause
    inner_directive 'machine|pause'
  end
  
  def send_reset
    inner_directive 'machine|reset'
  end
  
  def send_interrupt
    inner_directive 'machine|interrupt'
  end

  def send_reconnect
    self.reset
    inner_directive 'machine|reconnect'
  end

  def send_clean_all
    clean_all
    inner_directive 'machine|clean_all'
  end

  def clean_all
    directives.without_state(:done).each{|directive|
      if not directive.control?
        directive.clear || directive.force_stop
      end
    }
  end

  def properties
    env.enable_properties
  end
  
  def inner_directive command
    DirectiveGroup['default'].directive_templates[command].gen_directive(
        :room_id => room.id,
        :room_name => room.name,
        :machine_host => self.host,
        :machine => self
    )
  end
end
