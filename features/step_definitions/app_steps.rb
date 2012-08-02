# coding: utf-8
Given /创建了一个应用，名字是(.+)/ do |name|
  @app = App.reals.create :name => name.strip
end

And /应用(.+)包含机器(.+)/ do |app_name, ip|
  find_app(app_name).machines.create(:name => ip, :host => ip, :port => 22)
end


