default_group = DirectiveGroup.create(:name => 'default')

DirectiveTemplate.new(
  :name => 'machine|pause',
  :alias => 'machine|pause',
  :directive_group => default_group,
  :owner_id => 1
).save!

DirectiveTemplate.new(
  :name => 'machine|interrupt',
  :alias => 'machine|interrupt',
  :directive_group => default_group,
  :owner_id => 1
).save!

DirectiveTemplate.new(
  :name => 'machine|clean_all',
  :alias => 'machine|clean_all',
  :directive_group => default_group,
  :owner_id => 1
).save!

DirectiveGroup.create(:name => 'my_group')
