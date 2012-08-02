class AddPropertySupport < ActiveRecord::Migration
  def self.up

    rename_table  :envs, :properties
    rename_column :properties, :app_id, :resource_id
    add_column    :properties, :resource_type, :string

    create_table :envs do |t|
      t.integer :app_id
      t.string  :name
      t.timestamps
    end
    
    add_column :machines, :env_id, :integer
    
    self.update_app_and_machine_association

    self.update_property
  end

  def self.down
    remove_column :machines, :env_id
    drop_table    :envs
    remove_column :properties, :resource_type
    rename_column :properties, :resource_id, :app_id
    rename_table  :properties, :envs
  end
  
  def self.update_app_and_machine_association
    require 'machine.rb'
    require 'app.rb'
    App.find_each{|app| 
      env = app.envs.create :name => 'online'
      app.machines{|m|
        m.update_attribute :env_id, env.id
      }
    }
  end
  
  def self.update_property
    require 'property.rb'
    Property.all.each{|prop|
      prop.update_attribute(:resource_type, 'App')
    }
  end  
end
