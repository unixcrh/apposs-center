class DirectiveGroup < ActiveRecord::Base

  validates_uniqueness_of :name

  validates_presence_of :name
  
  belongs_to :owner, :class_name => 'User'

  has_many :directive_templates, :dependent => :nullify do
    def [] alias_name
      where(:alias => alias_name).first
    end

  end
  
  def self.[] name
    where(:name => name).first
  end

  def directive_templates_for_user user
    if self.is_default?
      directive_templates.order(:alias)
    else
      directive_templates.where(owner_id: user.id).order(:alias)
    end
  end

  def is_default?
    self.name == 'default'
  end

  def to_s
    name
  end
end
