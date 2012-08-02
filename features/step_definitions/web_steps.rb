# coding:utf-8
require 'watir-webdriver'

When /(.+)通过浏览器登录系统/ do |user_name|
  @browser = login user_name, 'http://127.0.0.1:3000'
end

When /访问(.+)/ do |resource|
  @browser.goto("http://127.0.0.1:3000#{resource}")
end

Then /^页面出现列表区：(.+)$/ do |title|
  @list_zone = get_list_zone_by_title(title)
end

Then /^页面出现表单区：(.+)$/ do |title|
  @form_zone = get_form_by_title(title)
end

And /应用列表与数据库数量一致/ do
  count = 0
  @browser.html.scan(/权限设定/){count += 1}
  count.should == App.reals.count
end

Then /^列表区出现表单：(.+)$/ do |title|
  legend = nil
  @browser.wait_until do
    legend = @list_zone.legend(:text, title)
    legend.exist?
  end
  @form = legend.parent.tap{|e| e.tag_name.should == 'form'}
end

Then /登录成功/ do
  @browser.text.should_not include('用户登录')
end

Then /^首页包含(.+)应用$/ do |app_name|
  @browser.elements(:css => '#app_nav li a').map(&:text).should include(app_name)
end

Then /机器列表中包含(.+)$/ do |machine_name|
  @browser.elements(:css => '#machines tr td label').collect do |ele|
    ele.attribute_value('title') =~ /(.+) \[/
    $1
  end.should include(machine_name)
end

When /^用户在其中执行(.+)$/ do |behaviour|
  @list_zone.link(:title, behaviour).click
end

When /^用户开始(.+)$/ do |behaviour|
  @browser.link(:text, behaviour).click
end

When /用户在表单中填写指令(.+)并提交/ do |command|
  ['alias','name'].each do |key|
    @form.text_field(:name, "directive_template[#{key}]").value = command
  end
  @form.input(:type,'submit').click
end

Then /^页面刷新列表区：(.+)$/ do |title|
  @list_zone = get_list_zone_by_title title
end

And /^列表区(.*)出现(.+)指令$/ do |predication, command|
  result = @list_zone.td(:text, command).exist? || @list_zone.li(:text, command).exist?
  if predication == '不'
    result.should be_false
  else
    result.should be_true
  end
end

When /^用户在其中删除(.+)指令$/ do |command|
  @browser.execute_script("window.confirm = function() {return true}")
  line_node = if @list_zone.td(:text, command).exist?
    @list_zone.td(:text, command)
  elsif @list_zone.li(:text, command).exist?
    @list_zone.li(:text, command)
  end
  line_node.parent.link(:text, "删除").click
  @browser.wait
end

When /^用户在(.+)上(.+)$/ do |title, command|
  get_list_zone_by_title(title).link(:text, command).click
end

And /列表区包含系统参数(.+)，值为(.+)/ do |name,value|
  @list_zone.text.should include(name)
  @list_zone.
    form(:action => "/backend/settings/#{name}").
      input(:name=>'settings[value]').
        value.should == value
end

When /用户设定系统参数(.+)的值为(.+)，并提交/ do |name,value|
  form = @list_zone.form(:action => "/backend/settings/#{name}")
  form.text_field(:name,'settings[value]').value = value
  form.input(:type,'submit').click
end

