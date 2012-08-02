class Software < ActiveRecord::Base
  
  NAME = 'PKG_NAME'

  belongs_to :app

  validates_uniqueness_of :name, :scope => [:app_id]
  validates_presence_of :name

  after_create :update_env

  def update_env
    app.properties[NAME] = name
  end
end
