# coding: utf-8
class AddDownloadDirective < ActiveRecord::Migration
  def self.up

    Property.create(
      :resource_type => Property::GLOBAL,
      :name => "profile_path", 
      :value => '/home/lifu/conf/pe.conf'
    )
    p "请更新 profile_path 全局变量"
    Property.create(
      :resource_type => Property::GLOBAL,
      :name => "site_url", 
      :value => 'http://127.0.0.1:9999'
    )
    p "请更新 site_url 全局变量"
  
    change_table :properties do |t|
      t.boolean :locked
    end
    
    App.reals.each{|app|
      app.properties.create :name => :app_id, :value => app.id, :locked => true
    }
    
    Env.find_each{|e|
      e.properties.create :name => :env_id, :value => e.id, :locked => true
    }

    group = DirectiveGroup.create(:name => 'default')

    DirectiveTemplate.new(
      :name  => 'mkdir -p `dirname $profile_path` ; wget "$site_url/store/$app_id/$env_id/pe.conf" -O "$profile_path" -o sync_profile.log && echo downloaded',
      :alias => 'sync_profile',
      :directive_group => group
    ).save!(:validate => false)
    DirectiveTemplate.new(
      :name  => 'machine|reset',
      :alias => 'machine|reset',
      :directive_group => group
    ).save!(:validate => false)
  end

  def self.down
    dg = DirectiveGroup.where(:name => 'default').first
    if dg
      dg.directive_templates.delete_all
      dg.delete
    end

    App.reals.each{|app|
      app.properties.where(:name => :app_id).first.delete rescue nil
    }
    
    Env.find_each{|e|
      e.properties.where(:name => :env_id).first.delete rescue nil
    }
    
    remove_column :properties, :locked
  end
end

