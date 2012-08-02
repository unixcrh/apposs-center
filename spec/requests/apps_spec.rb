# coding: utf-8
require 'spec_helper'

describe "Apps" do
  describe "GET /apps" do
    it "自动重定向至登录页面" do
      get apps_path
      response.status.should be(302)
    end
  end
end
