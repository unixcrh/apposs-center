class CreateMachineOperations < ActiveRecord::Migration
  def change
    create_table :machine_operations do |t|
      t.integer :machine_id
      t.integer :operation_id
      t.integer :operation_template_id

      t.timestamps
    end
  end
end
