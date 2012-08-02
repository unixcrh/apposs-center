# coding:utf-8
module BrowserHelpers
  def login user_name, url
    email = user_by_name(user_name).email
    # cucumber 模式下通过传入的 login_as 参数决定用户
    Watir::Browser.start("#{url}/?login_as=#{email}")
  end

  # 根据title获取列表区域
  def get_list_zone_by_title title
    title_node = nil
    sleep 0.1
    @browser.wait_until do
      title_node = @browser.h4(:text, title)
      title_node.exist?
    end
    main_node = title_node.   tap{|e| e.should_not be_nil}.
                    parent.   tap{|e| e.tag_name.should == "div" }
    if main_node.ul.exist?
      main_node.ul.tap{|e| e.class_name.should include('nav')}
    else
      main_node.table.tbody.tap{|e| e.should exist}
    end
    main_node
  end

  def get_form_by_title title
    legend = nil
    @browser.wait_until do
      legend = @browser.legend(:text, title)
      legend.exist?
    end
    legend.     tap{|e| e.should_not be_nil}.
      parent.   tap{|e| e.tag_name.should == "fieldset" }.
        parent. tap{|e| e.tag_name.should == 'form'}
  end
end

World(BrowserHelpers)
