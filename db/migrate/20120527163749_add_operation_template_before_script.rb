class AddOperationTemplateBeforeScript < ActiveRecord::Migration
  def up
    add_column :operation_templates, :begin_script, :string
  end

  def down
    remove_column :operation_templates, :begin_script
  end
end
