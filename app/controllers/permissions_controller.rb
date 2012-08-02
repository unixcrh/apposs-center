class PermissionsController < ResourceController

  before_filter :authenticate_pe!

  def begin_of_association_chain
    current_app
  end
end
