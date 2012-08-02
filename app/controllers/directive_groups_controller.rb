class DirectiveGroupsController < ApplicationController
  def index
    render :text => DirectiveGroup.all.to_json(:include => [:directive_templates])
  end
  
  def items
    group = DirectiveGroup.find(params[:id])
    if group.name == 'default'
      @collection = group.directive_templates
    else
      @collection = current_user.directive_templates.where(:directive_group_id => group.id)
    end
    respond_to do |format|
      format.js
    end
  end
end
