class AppAddLocked < ActiveRecord::Migration
  def up
    add_column :apps, :locked, :boolean
    add_index :envs, :name
  end

  def down
    remove_index :envs, :name
    remove_column :apps, :locked
  end
end
