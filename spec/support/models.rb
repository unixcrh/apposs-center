# coding: utf-8

module ModelHelpers
  def app_by_name name
    App.reals.where(:name => name).first
  end

  def user_by_email name
    User.where(:email => name).first
  end
end

RSpec.configure do |config|
  config.include ModelHelpers
end
