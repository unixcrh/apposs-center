# This migration comes from apposs_file (originally 20120723061841)
class AddLinkable < ActiveRecord::Migration
  def change
    change_table :apposs_file_file_entries do |t|
      t.boolean :linkable # true if resource is linked to target
    end
  end
end
