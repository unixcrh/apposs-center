# This migration comes from apposs_file (originally 20120514094910)
class CreateAppossFileFileEntries < ActiveRecord::Migration
  def change
    create_table :apposs_file_file_entries do |t|
      t.integer :app_id
      t.string  :refer_url
      t.string  :refer_type
      t.string  :path
      t.timestamps
    end
  end
end

