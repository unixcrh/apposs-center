class ApplicationController < ActionController::Base
  include Rails.configuration.adapter::Auth

  helper_method :current_user, :current_app
  protect_from_forgery
 
  def current_app
    @current_app ||= if session[:app_id]
                       current_user.apps.find_by_id(session[:app_id])
                     else
                       current_user.apps.where(:id => params[:app_id]).first
                     end
  end

  def change_current_app app_id
    session[:app_id] = app_id
    @current_app = nil
  end

  def authenticate_pe!
    if current_user.nil? || !current_user.is_pe?( current_app )
      redirect_to root_path
    end
  end

end
