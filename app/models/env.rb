class Env < ActiveRecord::Base
  belongs_to :app
  
  has_many :machines

  validates_uniqueness_of :name, :scope => [:app_id]
  
  attr_accessor :property_file, :property_content
  attr_accessible :property_file, :property_content, :name

  after_create :add_default_property

  before_save :load_property
  
  has_many :properties, :as => :resource do
    def [] name
      item = where(:name => name).first
      item.value if item
    end

    def []=name,value,locked=false
      item = where(:name => name).first
      if item.nil?
        new(:name => name, :value => value, :locked => locked).save!
      else
        item.update_attributes(:value => value, :locked => locked) && item
      end
    end

    def pairs
      all.inject({}){|hash,env| hash.update(env.name => env.value) }
    end
  end
  
  def add_default_property
    properties[:env_id, self.id] = true
  end

  def load_property
    if self.property_file
      data = property_file.read
      reload_property_data(data)
    else
      Rails.logger.info 'no property file'
    end

    if self.property_content
      reload_property_data self.property_content
    end
  end
  
  def reload_property_data data
    self.properties.not_lock.destroy_all
    data.split( /\r|\n/ ).reject{|m| m.length==0 }.each{|line|
      k,v = line.split('=')
      self.properties[k.strip]=v if v
    }
  end

  def enable_properties
    Property.global.pairs.
      update( app.properties.pairs).
      update( properties.pairs )
  end

  def export_profile
    prop_hash = enable_properties
    data = Property.build_property prop_hash
    if block_given?
      yield data
    end
  end
  
  def to_s
    self.name
  end
end
