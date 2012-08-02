# coding: utf-8
require 'spec_helper'

describe Role do

  fixtures :users,:roles,:apps,:stakeholders

  it "能够进行对象校验" do
    role = Role[Role::Admin]
    role.name.should == Role::Admin
    
    new_role = Role.new(:name => Role::Admin)
    new_role.valid?.should be_false
    new_role.errors.size.should == 1
    new_role.errors[:name].first.should == '已经被使用'
    
  end

  it "关联user对象" do
    user = User.first
    user.grant(Role::Admin,nil)
    user.is_admin?.should be_true

    role = Role[Role::Admin]
    role.name.should == Role::Admin
    role.users.first.should == user

  end

  it "查询非管理类角色" do
    Role.op_role_ids.should_not include( Role[Role::Admin].id )
    Role.op_role_ids.should_not include( Role[Role::PE].id )
  end
end
