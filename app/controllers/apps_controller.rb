# coding: utf-8
class AppsController < BaseController
  include Rails.configuration.adapter

  def index
    @apps = current_user.apps.order('name').uniq
    @first = @apps.first
    change_current_app @first.id if @first
  	render :layout => 'application'
  end

  def show
    @app = current_user.apps.find(params[:id])
    change_current_app @app.id if @app
    respond_to do |format|
      format.js
    end
  end
  

  def operations
    @app = current_user.apps.find(params[:id])
    @collection = @app.operations.without_state(:done)
    respond_to do |format|
      format.js
    end
  end

  def old_operations
    @app = current_user.apps.find(params[:id])
    @collection = @app.operations.where(:state => :done)
    respond_to do |format|
      format.js
    end
  end
  
  def reload_machines
    @app = current_user.apps.find(params[:id])
    MachineLoader.load @app.id
    respond_to do |format|
      format.js
    end
  end
end
