# encoding: utf-8
require 'spec_helper'

describe Permission do
  fixtures :apps,:permissions,:machines,:operation_templates
  
  describe "已有对象" do

    let(:permission){ Permission.first }

    it 'machines' do
      count = permission.machine_str.split(',').size
      permission.machines.size.should == count

      permission.machines = []
      permission.valid? # 触发回调
      permission.machine_str.should == ''
    end

    it 'operation_templates' do
      count = permission.operation_template_str.split(',').size
      permission.operation_templates.size.should == count

      permission.operation_templates = []
      permission.valid?
      permission.operation_template_str.should == ""
    end

    it 'find_by_operation_template' do
      Permission.by_operation_template(1).count.should == 1
      Permission.by_operation_template('1').count.should == 1
      Permission.by_operation_template('1,2').count.should == 1
      Permission.by_operation_template('0,2').count.should == 0
    end
  end
  
  describe "新建对象" do

    let(:permission){ App.reals.find(1).permissions.new }

    it 'machine_and_operation_template' do
      permission.machines.should == []
      permission.machines = []
      permission.valid?.should be_false
      permission.machine_str.should == ''
      
      permission.machines = %w{1 2}
      permission.valid?.should be_false
      permission.machine_str.should == '1,2'
      
      permission.operation_templates.should == []
      permission.operation_templates = []
      permission.valid?.should be_false
      permission.operation_template_str.should == ''

      permission.operation_templates = %w{1 2}
      permission.valid?.should be_false
      permission.operation_template_str.should == "1,2"

      permission.name = 'first'
      permission.valid?.should be_false # duplicate name
      permission.name = 'other'
      permission.valid?.should be_true
    end
  end
end
