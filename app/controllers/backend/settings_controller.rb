# coding: utf-8
class Backend::SettingsController < Backend::BaseController

  def collection
    @collection ||= Settings.all
  end
  
  def update
    Settings[params[:id]] = (params[:settings][:value] || 'updated')
    redirect_to backend_settings_path
  end

end
