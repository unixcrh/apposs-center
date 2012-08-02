class AddOuterIdAndIndex < ActiveRecord::Migration
  def change
    add_column :apps, :outer_identity, :string
    add_index  :apps, :outer_identity
    add_index  :operation_templates, :app_id
    add_index  :operations, :app_id
    add_index  :permissions, :app_id
    add_index  :directive_groups, :name
  end
end
