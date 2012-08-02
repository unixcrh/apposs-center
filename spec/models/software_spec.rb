# coding: utf-8
require 'spec_helper'

describe Software do
  fixtures :apps,:softwares
  it "应用与软件模型关联" do
    app = App.first
    app.softwares.count.should == 1
  end
end
