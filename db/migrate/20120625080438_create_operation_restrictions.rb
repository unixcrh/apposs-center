class CreateOperationRestrictions < ActiveRecord::Migration
  def change
    create_table :operation_restrictions do |t|
      t.integer :operation_template_id, :null => false
      t.integer :env_id               , :null => false
      t.integer :limit                , :null => false
      t.string :limit_cycle           , :null => false

      t.timestamps
    end
  end
end
