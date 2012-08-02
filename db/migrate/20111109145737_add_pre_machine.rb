class AddPreMachine < ActiveRecord::Migration
  def self.up
    App.reals.each{|app| app.envs[:pre,true] }
  end

  def self.down
  end
end
