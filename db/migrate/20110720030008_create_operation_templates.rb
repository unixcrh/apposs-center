class CreateOperationTemplates < ActiveRecord::Migration
  def self.up
    create_table :operation_templates do |t|
      t.string :name
      t.integer :app_id
      t.string :expression

      t.timestamps
    end

  end

  def self.down
    drop_table :operation_templates
  end
end
