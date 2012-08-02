class CreateStakeholders < ActiveRecord::Migration
  def self.up
    create_table :stakeholders do |t|
      t.integer :role_id
      t.integer :user_id
      t.integer :app_id

      t.timestamps
    end

    u = User.where(:email => 'lifu@taobao.com').first

    Stakeholder.new(
      :user_id => u.id, :role_id => Role[Role::Admin].id
    ).save!(:validate => false)
  end

  def self.down
    drop_table :stakeholders
  end
end

