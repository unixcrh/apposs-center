class RenameEnvKey < ActiveRecord::Migration
  def self.up
    rename_column :envs, :key, :name
  end

  def self.down
    rename_column :envs, :name, :key
  end
end
