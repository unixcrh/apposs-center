class CreateDirectives < ActiveRecord::Migration
  def self.up
    create_table :directives do |t|
      t.integer :operation_id
      t.integer :machine_id
      t.integer :directive_template_id
      t.boolean :next_when_fail
      t.string :state
      t.boolean :isok, :default => false
      t.text :response

      # 冗余字段
      t.integer :room_id
      t.string :room_name
      t.string :machine_host
      t.string :command_name

      # 时间戳
      t.timestamps
    end
    add_index :directives, "machine_id"
    add_index :directives, "state"
  end

  def self.down
    remove_index :directives, "machine_id"
    remove_index :directives, "state"
    drop_table :directives
  end
end
