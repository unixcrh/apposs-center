# coding: utf-8
require 'fileutils'

And /(.+)已经导入/ do |source|
  fixture case source
    when '应用和机器数据' then :inventory
    when '基础数据' then [:roles, :directive_groups]
    else source.split(/,/).map(&:to_sym) #1.9 syntax
  end
end

