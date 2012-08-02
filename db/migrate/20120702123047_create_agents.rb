class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :ipaddr
      t.string :name

      t.timestamps
    end

    add_index :agents, :ipaddr
    add_index :agents, :name
  end
end
