class CreateReleasePacks < ActiveRecord::Migration
  def self.up
    create_table :release_packs do |t|
      t.string  :version
      t.string  :branch
      t.integer :app_id
      t.string  :state
      
      t.timestamps
    end
  end

  def self.down
    drop_table :release_packs
  end
end
