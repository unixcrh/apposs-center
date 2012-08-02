# coding: utf-8
When /^(.+)被任命为(.+)的(.+)$/ do |user, app_name, role_name|
  app = find_app(app_name)
  find_or_create_user(user).grant Role[role_name], app
end

And /^(.+)被设为管理员$/ do |user|
  u = find_or_create_user(user)
  u.grant Role::Admin unless u.is_admin?
end
