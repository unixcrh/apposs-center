class Keyword < ActiveRecord::Base
  acts_as_taggable

  validates_presence_of :type
  
  def self.words
    select(:value).all.collect(&:value)
  end
end
