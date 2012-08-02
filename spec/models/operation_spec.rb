# coding: utf-8
require 'spec_helper'

describe Operation do
  fixtures :directive_groups, :directive_templates,
           :users, :roles, :apps, :stakeholders,
           :operation_templates,:rooms,:machines,
           :operation_restrictions
  it "从操作模板中创建一个普通的操作" do
    app = App.first
    ot = app.operation_templates.find 1
    directive_count = ot.expression.split(",").count
    directive_count.should == 3
    MachineOperation.count.should == 0
    oper = ot.gen_operation User.first, app.machines.collect{|m| m.id}
    MachineOperation.count.should == app.machines.count
    MachineOperation.last.operation_template_id.should == ot.id
    oper.directives.count.should == (directive_count * app.machines.count)
    machine = Machine.first
    oper2 = ot.gen_operation User.first,[machine.id]
    MachineOperation.count.should == app.machines.count + 1
    oper2.directives.count.should == directive_count
    oper2.directives.first.machine.should == machine
  end
  
  it "创建一个自动继续的操作序列" do

    MachineOperation.count.should == 0
    operations = build_operation_sequence(false)
    
    MachineOperation.count.should == operations.count
    first = operations.first
    second = first.next
    second.state.should == 'wait'

    complete_an_operation first
    
    first.reload
    first.state.should == 'done'
    second.reload
    second.state.should == 'init'
  end
  
  it "创建一个人工继续的操作序列" do
    MachineOperation.count.should == 0 
    operations = build_operation_sequence(true)
    MachineOperation.count.should == operations.count
    
    first = operations.first
    second = first.next
    second.state.should == 'hold'

    complete_an_operation first
    
    first.reload
    first.state.should == 'done'
    second.reload
    second.state.should == 'hold'
  end
 
  it '创建一个含有begin_script的operation' do
    app = App.first
    user = User.first
    ot = app.operation_templates.find 3
    ot.begin_script = "self.name = 'changed_name'"
    ot.gen_operation user, app.machines.map(&:id)
    ot.name.should == 'changed_name'
  end

  it '创建operation超过限制次数' do
    OperationRestriction.first.update_attribute :limit, 1
    app = App.first
    user = User.first
    ot = app.operation_templates.find 1
    count = Operation.count
    ot.gen_operation user, app.machines.map(&:id)
    Operation.count.should == count+1
    lambda{
      ot.gen_operation user, app.machines.map(&:id)
    }.should raise_error
  end

  def build_operation_sequence is_hold
    old_count = Directive.count
    app = App.first
    ot = app.operation_templates.last
    directive_count = ot.expression.split(",").count
    directive_count.should == 2
    user = User.first
    previous_id = nil
    user = User.first
    ss = app.machines.collect{|m| m.id}.collect{|x| [x]}
    ss.size.should == 4
    operations = ss.collect{|id_group|
      operation_on_bottom = ot.gen_operation(user, id_group, previous_id, is_hold )
      previous_id = operation_on_bottom.id
      operation_on_bottom
    }
    first = operations.first
    first.enable
    first.state.should == "init"
    Directive.count.should == old_count + ss.size * directive_count
    operations
  end
  
  def complete_an_operation operation
    operation.directives.each{|dire|
      dire.download && dire.invoke && dire.ok
    }
    operation
  end
end
