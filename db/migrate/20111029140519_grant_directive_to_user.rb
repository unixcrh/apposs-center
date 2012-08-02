class GrantDirectiveToUser < ActiveRecord::Migration
  def self.up
    change_table :directive_templates do |t|
      t.integer :owner_id
    end
    
    if role = Role[Role::Admin] and admin = role.users.first
      admin_id = admin.id
    else
      admin_id = 1
    end
    
    if role = Role[Role::PE] and pe = role.users.first
      user_id = pe.id
    else
      user_id = 1
    end
    
    default_group_id = DirectiveGroup['default'].id
    DirectiveTemplate.find_each do |dt|
      if dt.directive_group_id == default_group_id
        dt.update_attribute :owner_id, admin_id
      else
        dt.update_attribute :owner_id, user_id
      end
    end
    
    DirectiveGroup.create(:name => 'my_group')
  end

  def self.down
    change_table :directive_templates do |t|
      t.remove :owner_id
    end
  end
end
