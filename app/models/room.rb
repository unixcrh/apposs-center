class Room < ActiveRecord::Base
  has_many :machines, :dependent => :nullify
  validates_uniqueness_of :name

  def to_s
    send :name
  end
end
