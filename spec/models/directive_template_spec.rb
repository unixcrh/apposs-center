# coding: utf-8
require 'spec_helper'

describe DirectiveTemplate do

  fixtures :directive_templates, :directive_groups, :apps, :envs, :properties

  before :each do
    env = App.first.envs['线上']
    env.properties[:env_id].should == '1'
    @machine = env.machines.create :name => 'for_directive_test', :port => 22
    @data = {
      :machine => @machine,
      :params => env.enable_properties
    }
  end

  it '创建内置指令' do
    directive = make_directive 'inner', @data
    directive.command_name.should == 'do inner'
  end
  
  it '成功创建 sync_profile 指令' do
    command_name = make_directive('sync_profile', @data).command_name
    command_name.include?('$').should be_false
    #'mkdir -p `dirname /home/test/conf/pe.conf` && wget "http://127.0.0.1:9999/store/1/1/pe.conf" -O "/home/test/conf/pe.conf"'
  end

  it '成功创建 machine|reset 指令' do
    directive = make_directive 'machine|reset', @data
    @machine.reload.directives.count.should == 1
    @machine.directives.first.command_name.should == 'machine|reset'
  end
  
  def make_directive name, data
    DirectiveGroup['default'].directive_templates[name].gen_directive data
  end
end

