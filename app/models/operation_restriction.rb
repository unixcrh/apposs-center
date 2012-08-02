class OperationRestriction < ActiveRecord::Base
  attr_accessible :env_id, :limit, :limit_cycle, :operation_template_id
  validates_numericality_of :limit, :greater_than_or_equal_to => 0

  before_create :set_default_value

  def set_default_value
    self.limit_cycle  = 'W' # 操作限制以星期为一个周期
  end
end
