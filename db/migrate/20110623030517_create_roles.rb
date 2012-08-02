class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end
    
    admin_role = Role.create(:name => Role::Admin)
    pe_role = Role.create(:name => Role::PE)
    appops_role = Role.create(:name => Role::APPOPS)
  end

  def self.down
    drop_table :roles
  end
end
