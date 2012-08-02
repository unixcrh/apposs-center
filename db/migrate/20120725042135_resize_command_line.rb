class ResizeCommandLine < ActiveRecord::Migration
  def up 
    change_column :directives,          :command_name, :string, :limit => 1024
    change_column :directive_templates, :name,         :string, :limit => 1024
  end

  def down
    change_column :directive_templates, :name,         :string, :limit => 255
    change_column :directives,          :command_name, :string, :limit => 255
  end

end
