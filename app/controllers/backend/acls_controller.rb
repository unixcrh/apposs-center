# coding: utf-8
class Backend::AclsController < Backend::BaseController

  defaults :resource_class => Stakeholder
  
  belongs_to :app
  
  respond_to :js
  
end
