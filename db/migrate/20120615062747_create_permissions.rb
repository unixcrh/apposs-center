class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :app_id
      t.string  :name
      t.string  :operation_template_str, :limit => 2048
      t.string  :machine_str,   :limit => 8192

      t.timestamps
    end
  end
end
