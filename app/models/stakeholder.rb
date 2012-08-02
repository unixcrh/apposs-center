# coding: utf-8

# 其实就是一个基于Role 的 ACL 
class Stakeholder < ActiveRecord::Base

  belongs_to :user

  belongs_to :role

  belongs_to :resource, :polymorphic => true
  
  validates_presence_of :user_id, :role_id
  
  validates_uniqueness_of :role_id, :scope => [:user_id, :resource_id, :resource_type]

  attr_accessor :email, :role_name
  
  before_validation :fulfill_other
  
  def fulfill_other
    if self.user_id.nil? and self.email
      u = User.where(:email => self.email).first
      self.user_id = u.id if u
    end
    
    if self.role_id.nil? and self.role_name
      role = Role[self.role_name]
      self.role_id = role.id if role
    end
  end
end
