# coding: utf-8
class DirectiveTemplate < ActiveRecord::Base

  GLOBAL_ID = 0

  belongs_to :directive_group

  belongs_to :owner, :class_name => 'User'
  
  validates_uniqueness_of :alias, :scope => [:directive_group_id, :owner_id]
  
  validates_presence_of :name,:alias

  validates_length_of :name, maximum: 512
  
  has_many :directives
  
  before_save :clean_line_break

  def clean_line_break
    self.name = self.name.
      delete("\r").
      gsub( /\n+/, ' && ' ).
      gsub(/ && +&& /, ' && ').
      gsub(/(^ +&&|&& +$)/,'')
  end

  def gen_directive params
    directives.create(
      {
        :command_name => self.name,
        :operation_id => Operation::DEFAULT_ID,
        :next_when_fail => true,
      }.update(params)
    )
  end
  
  def to_s
    self.alias || self.name
  end
  
end
