# coding: utf-8
require 'spec_helper'

describe ApiController do

#  render_views
  
  fixtures :directive_groups, :directive_templates,
           :users, :apps, :roles, :stakeholders,
           :operation_templates,:rooms,:machines,:agents

  describe "获取所有指令" do
  
    it "没有新的指令" do
      get :commands,:room_name => 'CNZ'
      response.body.to_s.should be_empty
    end
    
    it "有新的指令" do
      app = App.first
      ot = app.operation_templates.where(:name => 'upgrade package').first
      oper = ot.gen_operation User.first, app.machines.collect{|m| m.id}

      app.machines.collect{|m| m.room_id}.uniq.each do |room_id|
        room = Room.find room_id
        machine_count = app.machines.where(:room_id => room_id).count
        amount = ot.expression.split(/,/).count * machine_count
        get :commands, :room_name => room.name
        response.should be_success
        response.body.split(/\n/).count.should == amount
      end
    end
  end

  describe "变更机器状态" do
    it "访问已存在的机器" do
      m = Machine.first
      {
        :reset => :normal, 
        :disconnect => :disconnected,
        :pause => :paused
      }.each_pair do |event,state|
        get :machine_on, :host => m.host, :event => event.to_sym
        response.should be_success
        response.body.should == "#{m.host}|true"
        m.reload.state.should == state.to_s
      end
    end

    it "访问不存在的机器" do
      m = Machine.first
      get :machine_on, :host => "unknown host", :state => :pause
      response.status.should == 404
    end
  end
  
  describe "指令处理结果反馈" do
    before :each do
      app = App.first
      ot = app.operation_templates.where(:name => 'upgrade package').first
      oper = ot.gen_operation( User.first, app.machines.collect{|m| m.id} )
      oper.directives.each do |directive|
        directive.download
      end
      @first_directive,@second_directive = oper.directives[0..1]
      get :run, :oid => @first_directive.id
      @first_directive.reload
      @first_directive.running?.should be_true
    end

    it '指令执行成功' do
      get :callback, :oid => @first_directive.id, :isok => :true, :body => 'well done'
      @first_directive.reload
      @first_directive.done?.should be_true
      @first_directive.response.should == 'well done'
    end

    it '指令执行失败' do
      get :callback, :oid => @first_directive.id, :isok => :false, :body => 'fail'
      @first_directive.reload
      @first_directive.failure?.should be_true
      @first_directive.response.should == 'fail'
    end

    it '反馈信息支持GBK编码' do
      get :callback, {
        :oid => @first_directive.id, 
        :isok => :true,
        :body => "\xC4\xE3\xBA\xC3"
      }
      @first_directive.reload
      @first_directive.done?.should be_true
      @first_directive.response.should == '你好'
    end
  end
end
