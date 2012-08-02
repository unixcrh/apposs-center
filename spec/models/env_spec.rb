# coding: utf-8
require 'spec_helper'

describe Env do
  fixtures :apps, :envs, :properties
  
  before :each do
    @env = Env.first
    @env.properties.count.should == 3
    @env.enable_properties.count.should == 9
  end
  
  describe '访问自身的 property' do
    it '创建普通属性' do
      @env.properties[:a] = 'b'
      @env.reload
      @env.properties[:a].should == 'b'
    end
    
    it '修改固有属性' do
      @env.properties[:a, :b] = true
      @env.reload
      @env.properties.where(:name => :a).first.locked.should be_true
    end
    
    it '创建固有属性' do
      @env.properties[:other, 'sth'] = true
      @env.reload
      @env.properties.where(:name => :other).first.locked.should be_true
    end

    it "当前环境的有效的配置项信息（覆盖后结果）" do
      @env.enable_properties['software'].should == 'env 1 software'
    end
  end

  describe '更新配置信息' do

    before :each do
      @env = Env.first
      @env.properties.destroy_all
      @env.reload
    end

    it '文件更新' do
      @env.property_file = File.new(
        "#{Rails.root}/spec/fixtures/env_property.txt"
      )
      @env.save.should be_true
      check_property @env
    end

    it "直接更新" do
      @env.property_content = %Q|
  [config]
  url=www.mysite.com\nstatus=/home/status_ns.html\rpackage=site_pkg
  package_addr=http://www.mysite.com/taobao/site_pkg-1.0.rpm
  newpackage=site_pkg.rpm
  |
      @env.save.should be_true
      check_property @env
    end

    def check_property env_obj
      env_obj.reload.properties['url'].should == 'www.mysite.com'
      env_obj.properties['package'].should == 'site_pkg'
      env_obj.properties['newpackage'].should == 'site_pkg.rpm'

      env_obj.properties.size.should == 5

      env_obj.properties.destroy_all
      env_obj.property_content = nil
      env_obj.save.should be_true
    end
  end
  
  describe '通用功能' do
    it "输出配置信息" do
      @env.export_profile do |data|
        data.include?('root').should be_true
        data.include?('app_id').should be_true
        data.include?('env_id').should be_true
      end
    end
    
    it "创建 env 时增加缺省的 property" do
      app = App.first
      env = app.envs.create :name => 'not_exist'
      env.properties.count.should == 1
      env.reload
      env.properties[:env_id].should == env.id.to_s
      env.properties(:name => :env_id).first.locked.should == true
    end
  end
end
