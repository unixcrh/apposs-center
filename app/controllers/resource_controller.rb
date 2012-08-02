# encoding: utf-8
class ResourceController < InheritedResources::Base

  layout false
  respond_to :js,:xml

  def current_app
    current_user.apps.where(:id => params[:app_id]).first||App.new
  end
  
  def event
    if resource.events_for_user.include? params[:event].to_sym # 防止注入攻击
      @result = resource.send params[:event].to_sym
    end
  end
  
  protected
    def begin_of_association_chain
      @current_user
    end

end
