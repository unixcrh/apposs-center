# coding: utf-8
require 'fileutils'
class EnvsController < ResourceController
  
  respond_to :html

  def edit
    app = App.find( params[:app_id])
    @env = app.envs.find params[:id]
    app_props = @env.app.properties.not_lock.pairs
    env_props = @env.properties.not_lock.pairs
    @env.property_content = app_props.update( env_props ).
      collect{|k,v| "#{k}=#{v}"}.
      join("\n")
  end

  def update
    env = App.find( params[:app_id]).envs.find params[:id]
    if env.update_attributes( params[:env].slice :property_content, :property_file )
      env.export_profile do |data|
        file_folder = "#{Rails.root}/public/store/#{env.app.id}/#{env.id}"
        FileUtils.mkdir_p file_folder unless File.exist? file_folder
        File.open("#{file_folder}/pe.conf","w"){|f| f.write data }
      end
    else
      render :upload_properties
    end
  end
end
