class CreateSoftwares < ActiveRecord::Migration
  def self.up
    create_table :softwares do |t|
      t.string  :name
      t.integer :app_id

      t.timestamps
    end
  end

  def self.down
    drop_table :softwares
  end
end
