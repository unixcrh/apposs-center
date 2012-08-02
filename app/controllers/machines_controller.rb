class MachinesController < ResourceController

  def change_user
    @machine_ids = check_machine_ids(params[:machine_ids])
    
    @failed_machines = current_user.
                                    owned_machines(App.find(params[:app_id])).
                                    where(:id => @machine_ids).inject([]) do |arr, machine|
      if machine.update_attribute :user, params[:data]
        arr
      else
        arr << machine
      end
    end
  end
  
  #TODO 没有检查machine是否属于当前用户
  def change_env
    @machine = Machine.find(params[:id])
    env_obj = @machine.app.envs.find params['env_id']
    @machine.update_attribute :env, env_obj
  end
  
  def reset
    @machine = Machine.find(params[:id])
    @directive = @machine.send_reset
  end
  
  def clean_all
    @machine = Machine.find(params[:id])
    @directive = @machine.send_clean_all
  end
  
  def interrupt
    @machine = Machine.find(params[:id])
    @directive = @machine.send_interrupt
  end
  
  def pause
    @machine = Machine.find(params[:id])
    @directive = @machine.send_pause
  end
  
  def reconnect
    @machine = Machine.find(params[:id])
    @directive = @machine.send_reconnect
  end
  
  def directives
    @directives = Machine.find(params[:id]).directives.without_state(:done).desc
  end
  
  def old_directives
    @directives = Machine.find(params[:id]).directives.where(:state => :done).desc
  end

  def check_machine_ids machine_ids
    (machine_ids||[]).collect { |s| s.to_i }.uniq
  end
end
