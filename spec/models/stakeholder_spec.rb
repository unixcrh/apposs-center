# coding: utf-8
require 'spec_helper'

describe Stakeholder do
  fixtures :users,:apps,:stakeholders,:roles
  it '正常访问相关数据' do
    Stakeholder.count.should == 2
    Stakeholder.find(1).resource.is_a?(App).should == true
    
  end
  
  it '访问关联用户' do
    u = User.find 1
    u.acls.count.should == 2
    u.apps.first.should_not be_nil
  end
  
  it '访问关联应用' do
    app = App.find 1
    app.acls.count.should == 2
    app.operators.count.should == 2
  end
end
