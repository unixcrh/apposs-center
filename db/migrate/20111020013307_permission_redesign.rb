class PermissionRedesign < ActiveRecord::Migration
  def self.up
    add_index :roles, :name
    change_table :stakeholders do |t|
      t.rename :app_id, :resource_id
      t.string :resource_type
    end

    role = Role[Role::PE]

    if not role.nil?
      role_id = role.id

      Stakeholder.find_each do |ss|
        if (ss.resource_type.nil? and ss.role_id == role_id)
          ss.update_attribute(:resource_type, 'App')
        end
      end
    end
  end

  def self.down
    change_table :stakeholders do |t|
      t.remove :resource_type
      t.rename :resource_id, :app_id
    end
    remove_index :roles, :name
  end
end
