class AddDirectiveForMachine < ActiveRecord::Migration
  def self.up

    default_group = DirectiveGroup.where(:name => 'default').first

    DirectiveTemplate.new(
      :name => 'machine|pause',
      :alias => 'machine|pause',
      :directive_group => default_group
    ).save!(:validate => false)
    DirectiveTemplate.new(
      :name => 'machine|interrupt',
      :alias => 'machine|interrupt',
      :directive_group => default_group
    ).save!(:validate => false)
    DirectiveTemplate.new(
      :name => 'machine|clean_all',
      :alias => 'machine|clean_all',
      :directive_group => default_group
    ).save!(:validate => false)
  end

  def self.down
    default_group = DirectiveGroup.where(:name => 'default').first

    DirectiveTemplate.where(
      :name => 'machine|pause'
    ).delete_all
    DirectiveTemplate.where(
      :name => 'machine|interrupt'
    ).delete_all
    DirectiveTemplate.where(
      :name => 'machine|clean_all'
    ).delete_all
  end
end
