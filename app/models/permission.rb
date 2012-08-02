class Permission < ActiveRecord::Base
  attr_accessible :machines, :operation_templates
  attr_accessible :app_id, :name
  attr_accessor :machines, :operation_templates

  belongs_to :app

  scope :by_operation_template, lambda{|operation_template_id| 
    where('operation_template_str REGEXP ?', ["[^0-9]?#{operation_template_id.to_i}[^0-9]?"])
  }

  validates_uniqueness_of :name, :scope => :app_id
  validates_presence_of   :machine_str, :operation_template_str, :name

  before_validation :update_machines_and_operation_templates

  def self.map_for field
    field = "#{field.to_s.singularize}_str".to_sym
    select(field).map{|x| x.send field}.             # [',1,2,3','4,5']
      join(',').                                     # ',1,2,3,4,5'
      split(',').                                    # ['','1','2','3','4','5']
      delete_if(&:empty?).                           # ['1','2','3','4','5']
      map(&:to_i)                                    # [1,2,3,4,5]
  end

  def update_machines_and_operation_templates
    if app
      self.machine_str = 
        app.machines.
        where( id: self.machines.delete_if(&:empty?).map(&:to_i) ).
        map(&:id).sort.uniq.join(',')
      self.operation_template_str = 
        app.operation_templates.
        where( id: self.operation_templates.delete_if(&:empty?).map(&:to_i) ).
        map(&:id).sort.uniq.join(',')
    end
  end

  def machines
    @machines ||= self.machine_str.nil? ? [] : self.machine_str.split(',')
  end

  def operation_templates
    @operation_templates ||= self.operation_template_str.nil? ? [] : self.operation_template_str.split(',')
  end

end
