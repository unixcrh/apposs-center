require 'singleton'

class System

  include Singleton


  attr_accessor :id
  
  def initialize
    self.id = 1
  end  
end
