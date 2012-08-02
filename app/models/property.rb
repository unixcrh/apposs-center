# coding: utf-8

# 特别说明：
#   locked 字段用于区分系统设置的属性和用户设置的属性
#   系统缺省的属性由apposs创建，例如：app_id, env_id
#   系统缺省属性主要是用于一些内置指令的运行，例如：profile_sync 需要上述属性
#   系统缺省的属性对用户是不可见的，也不允许用户覆盖
class Property < ActiveRecord::Base
  GLOBAL = "GLOBAL"

  belongs_to :resource, :polymorphic => true

  validates_uniqueness_of :name, :scope => [:resource_type,:resource_id]

  scope :global, where(:resource_type => Property::GLOBAL)
  
  scope :not_lock, where('locked = false or locked is null')
  
  def self.pairs
    all.inject({}){|hash,env| hash.update(env.name => env.value) }
  end

  def self.build_property hash
    "[config]\n" + hash.collect{|k,v| "#{k}=#{v}"}.join( "\n" )
  end
end
