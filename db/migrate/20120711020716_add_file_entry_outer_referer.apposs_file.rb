# This migration comes from apposs_file (originally 20120710091848)
class AddFileEntryOuterReferer < ActiveRecord::Migration
  def change
    change_table :apposs_file_file_entries do |t|
      t.integer :operation_template_id
      t.integer :directive_template_id
    end

  end
end
