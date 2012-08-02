# coding: utf-8
class DirectivesController < ResourceController
  def body
    @directive = Directive.find params[:id]
  end
end
