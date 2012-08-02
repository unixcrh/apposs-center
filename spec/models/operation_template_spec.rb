# coding: utf-8
require 'spec_helper'

describe OperationTemplate do
  fixtures :operation_templates,:operation_restrictions,
           :machines, :apps, :envs

  describe 'restriction' do
    let(:template) { OperationTemplate.first }

    it '支持下标访问' do
      template.restrictions.count.should > 0
      template.restrictions[template.app.envs.first].should_not be_nil
      template.restrictions[0].should_not be_nil
    end

    it '正确设置和更新限制条件' do
      env = template.app.envs['预发']
      template.restriction_obj = { env.name => 20 }
      template.update_restrictions
      template.restrictions[env].tap do |o|
        o.env_id.should == env.id
        o.limit.should == 20
      end

      template.restriction_obj = { env.name => 10 }
      template.update_restrictions
      template.restrictions[env].tap do |o|
        o.env_id.should == env.id
        o.limit.should == 10
      end
      
    end

    it '限制数不能小于0' do
      env = template.app.envs['预发']
      template.restriction_obj = { env.name => -1 }
      lambda{template.update_restrictions}.should raise_error
    end
  end
end
