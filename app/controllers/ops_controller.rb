# encoding: utf-8
class OpsController < ResourceController

  before_filter :authenticate_pe!

  def index
    @resources = current_app.ops
  end

  def create
    if user = User.find_by_email(params[:op][:email])
      user.grant Role::APPOPS, current_app
    else
      @error = '用户不存在'
    end
  end

  def destroy
    if op = current_app.ops.find_by_id( params[:id] )
      op.ungrant Role::APPOPS, current_app
    end
  end

  def begin_of_association_chain
    current_app
  end

end
