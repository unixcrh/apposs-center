# coding: utf-8
Given /系统包含参数(.+)，值为(.+)/ do |name,value|
  Settings[name] = value
end

