# coding: utf-8
require 'spec_helper'

describe User do
  fixtures :users,:roles,:apps, :stakeholders
  
  before :each do
    @u = User.find 1
  end

  describe '执行赋权操作' do
    it '管理员角色' do
      @u.is_admin?.should be_false
      # 返回值表示保存成功
      @u.grant(Role::Admin,nil).new_record?.should be_false
      # 重复赋权会导致保存失败
      @u.grant(Role::Admin,nil).new_record?.should be_true
      @u.is_admin?.should be_true
    end
    
    it 'PE角色' do
      @u.is_pe?(App.find(1)).should be_true
      @u.ungrant(Role::PE, App.find(1)).should_not be_nil
      @u.is_pe?(App.find(1)).should be_false
      @u.grant(Role::PE, App.find(1)).new_record?.should be_false
      @u.is_pe?(App.find(1)).should be_true
    end
    
    it 'APPOPS角色' do
      @u.is_appops?(App.find(1)).should be_true
      @u.ungrant(Role::APPOPS, App.find(1)).should_not be_nil
      @u.is_appops?(App.find(1)).should be_false
    end
    
    it '获取正确的ACL' do
      @u.acls[App].map(&:resource).should == @u.apps
    end
  end

  describe '通用功能' do
    fixtures :machines,:directive_templates,:permissions, :operation_templates
    it "列举所负责的机器" do
      app = App.find 1

      app.machines.first.update_attribute :env, app.envs[:pre,true]
      @u.owned_machines(app).should == app.machines
      @u.ungrant(Role::PE, app)
      @u.owned_machines(app).count.should == 3
      @u.owned_machines(app, 1).count.should == 1 # permission.machine_str is '3'
    end

    it "列举能执行的操作" do
      app = App.find 1
      @u.owned_operation_templates(app).count.should == 3
      @u.ungrant(Role::PE, app)
      @u.owned_operation_templates(app).count.should == 2
    end
    
    it "导入指令" do
      expect{
        @u.load_directive_templates DirectiveTemplate.where(:id => [4,5])
      }.to change { 
        @u.directive_templates.count+DirectiveTemplate.count
      }.by(4)
    end
  end
end
