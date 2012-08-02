class ReleasePack < ActiveRecord::Base

  NAME = 'VERSION'

  belongs_to :app
  
  def vnumber
    version =~ /(\d+)(\.\d+)?$/
    $1
  end

  def use
    app.properties[NAME] = self.version
  end
end
