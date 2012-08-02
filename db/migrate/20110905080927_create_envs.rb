class CreateEnvs < ActiveRecord::Migration
  def self.up
    create_table :envs do |t|
      t.integer :app_id
      t.string  :key
      t.string  :value
      t.timestamps
    end

    add_index :envs, :key
    add_index :envs, :app_id

  end

  def self.down
    remove_index :envs, :key
    remove_index :envs, :app_id

    drop_table :envs
  end
end
