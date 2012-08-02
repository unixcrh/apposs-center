# coding: utf-8
require 'spec_helper'

describe Keyword do
  
  describe '创建' do
    it '支持 Dangerous 子类创建' do
      dangerous = Dangerous.create :value => 'rm'
      dangerous.type.should == 'Dangerous'
      Keyword.subclasses.should include(Dangerous)
    end
    
    it '不支持本身创建' do
      Keyword.new(:value => 'mv').valid?.should be_false
    end
  end
  
  describe '访问、修改' do
    fixtures :keywords
    it '支持简洁的访问api' do
      Dangerous.words.count.should == 2
      Dangerous.words.should include('mv')
      Keyword.words.count.should == 3
    end
    
    it '支持标签访问' do
      danger = Dangerous.first
      danger.tag_list = %w{shell,delete}
      danger.save!
      danger.tags.count.should == 2
    end
  end
end
