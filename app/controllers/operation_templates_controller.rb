# coding: utf-8
class OperationTemplatesController < ResourceController

  # 创建一个操作实例
  def execute
    @choosed_machine_ids = check_machine_ids(params[:machine_ids])
    if @choosed_machine_ids.size > 0
      begin
        @operation = OperationTemplate.
          find(params[:id]).
          gen_operation(current_user, @choosed_machine_ids)
      rescue Exception => e
        Rails.logger.error "execute fail: #{e.backtrace.join("\n")}"
        @error = e.message
      end
    end
  end

  def group_form
    
  end

  # 分组创建操作实例
  def group_execute
    group = params[:group]
    if group[:group_count] && group[:group_count].to_i > 0
      @operations = OperationTemplate.find(params[:id]).gen_operation_by_group(
        current_user,
        group[:group_count].to_i,
        group[:is_hold]=='1'
      )
    else
      @errmsg = '分组数应当是数字'
    end

  end

  private
  def check_machine_ids machine_ids
    (machine_ids||[]).collect { |s| s.to_i }.uniq
  end
end
