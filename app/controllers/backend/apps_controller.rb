# coding: utf-8
class Backend::AppsController < Backend::BaseController

  def collection
    @collection ||= App.reals
  end

end
