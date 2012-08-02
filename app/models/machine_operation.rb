class MachineOperation < ActiveRecord::Base
  attr_accessible :machine_id, :operation_id, :operation_template_id
  belongs_to :machine
  belongs_to :operation
  belongs_to :operation_template
end
