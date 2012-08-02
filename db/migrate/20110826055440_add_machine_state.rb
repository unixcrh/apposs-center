class AddMachineState < ActiveRecord::Migration
  def self.up
    add_column :machines, :state, :string
  end

  def self.down
    remove_column :machines, :state
  end
end
