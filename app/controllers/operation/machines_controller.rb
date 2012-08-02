class Operation::MachinesController < ResourceController

  def index
    @machines = Operation.find(params[:operation_id]).machines.uniq
  end

  def directives
    @directives = Directive.where(:operation_id => params[:operation_id], :machine_id => params[:id])
  end

end
