class CreateDirectiveGroups < ActiveRecord::Migration
  def self.up
    create_table :directive_groups do |t|
      t.string :name

      t.timestamps
    end

  end

  def self.down
    drop_table :directive_groups
  end
end
