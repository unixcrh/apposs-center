class AddReconnect < ActiveRecord::Migration
  def self.up
    default_group = DirectiveGroup.where(:name => 'default').first

    DirectiveTemplate.new(
      :name => 'machine|reconnect',
      :alias => 'machine|reconnect',
      :directive_group => default_group
    ).save!(:validate => false)
  end

  def self.down
    default_group = DirectiveGroup.where(:name => 'default').first

    DirectiveTemplate.where(
      :alias => 'machine|reconnect'
    ).delete_all
  end
end
