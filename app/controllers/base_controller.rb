class BaseController < ApplicationController
  respond_to :json
  before_filter :sso_auth
end
