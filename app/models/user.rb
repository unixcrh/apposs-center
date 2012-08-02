class User < ActiveRecord::Base
#  # Include default devise modules. Others available are:
#  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
#  devise :database_authenticatable,
#         :recoverable, :rememberable, :trackable, :validatable
#
#  # Setup accessible (or protected) attributes for your model
#  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :acls, :class_name => 'Stakeholder' do
    def [] name
      self.where(:resource_type => name).includes([:resource])
    end
  end
  
  has_many :apps, :through => :acls, :source => :resource, :source_type => 'App'
  has_many :roles,:through => :acls
  
  has_many :operations, :foreign_key => "operator_id"

  has_many :directive_templates, :foreign_key => 'owner_id'
  
  has_many :directive_groups, :foreign_key => 'owner_id'

  def load_directive_templates new_directive_templates
    new_directive_templates.each do |dt|
      directive_templates << dt.dup
    end
    directive_templates
  end

  def grant role, resource = nil
    role = Role[role] if role.is_a?(String)
    resource = System.instance if resource.nil?
    self.acls.create(
      :role_id => role.id, 
      :resource_type => resource.class.to_s, 
      :resource_id => resource.id
    )
  end
  
  def ungrant role_name, resource = nil
    role = Role[role_name]
    resource = System.instance if resource.nil?
    self.acls.where(
      :role_id => role.id, 
      :resource_type => resource.class.to_s, 
      :resource_id => resource.id
    ).delete_all
  end

  def is_admin?
    not self.acls.where(:role_id => Role[Role::Admin].id).first.nil?
  end
  
  def is_pe? resource
    has_assign? Role[Role::PE], resource
  end

  def is_appops? resource
    has_assign? Role[Role::APPOPS], resource
  end
  
  def has_assign? role, resource = nil
    resource = System.instance if resource.nil?
    not acls.where(
      :role_id => role.id, 
      :resource_type => resource.class.to_s, 
      :resource_id => resource.id
    ).first.nil?
  end
  
  def owned_machines app, operation_template_id = nil
    if is_pe?(app)
      app.machines
    elsif is_appops?(app)
      permissions = if operation_template_id
        app.permissions.by_operation_template(operation_template_id)
      else
        app.permissions
      end
      app.machines.where id: permissions.map_for(:machines)
    else
      []
    end
  end

  def owned_operation_templates app
    if is_pe?(app)
      app.operation_templates
    elsif is_appops?(app)
      app.operation_templates.where id: app.permissions.map_for(:operation_templates) 
    end
  end

end

