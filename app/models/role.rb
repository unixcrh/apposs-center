# coding: utf-8
class Role < ActiveRecord::Base
  has_many :stakeholders

  Admin = "Admin"
  PE = "PE"
  APPOPS = "APPOPS"
  
  validates_uniqueness_of :name
  
  has_many :acls, :class_name => 'Stakeholder'
  has_many :users, :through => :acls
  
  def self.[] name
    Role.where(:name => name).first
  end
  
  # 非管理类角色的 ID 列表，目前仅有 APPOPS 一种，未来可能添加其它类型
  # 特点说明：本身不能对应用进行管理，而只能在PE指定的范围内进行操作
  def self.op_role_ids
    Role.select(:id).map(&:id) - [Role[Role::PE].id, Role[Role::Admin].id]
  end

end
