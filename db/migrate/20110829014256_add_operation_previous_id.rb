class AddOperationPreviousId < ActiveRecord::Migration
  def self.up
    add_column :operations, :previous_id, :integer
  end

  def self.down
    remove_column :operations, :previous_id
  end
end
