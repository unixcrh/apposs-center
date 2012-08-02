class AppAsTree < ActiveRecord::Migration
  def self.up
    add_column :apps, :parent_id, :integer
    add_column :apps, :virtual, :boolean
    add_column :apps, :state, :string

    require 'app.rb'
    App.where('state is null').each{|app|
      app.update_attributes :virtual => false, :state => 'running', :parent_id => 0
    }
#    add_column :operations, :hosts, :text
  end

  def self.down
    remove_column :apps, :virtual
    remove_column :apps, :parent_id
    remove_column :apps, :state

#    remove_column :operations, :hosts, :text
  end
end
