# coding: utf-8
module MachinesHelper
  def machine_actions machine
    normal = (machine.state == 'normal')
    actions = []
    actions << link_to(raw('<i class="icon-list"></i>本机指令'), directives_machine_path(machine.id), :remote => true )
    if normal
    actions << link_to(raw('<i class="icon-pause"></i>暂停'), pause_machine_path(machine.id), :remote => true, :method => :put)
    actions << link_to(raw('<i class="icon-ban-circle"></i>强制停止'), interrupt_machine_path(machine.id), :remote => true, :method => :put, :confirm => "确实要强制暂停吗？")
    else
      actions << link_to(raw('<i class="icon-play"></i>继续'), reset_machine_path(machine.id), :remote => true, :method => :put)
    end
    actions << link_to(raw('<i class="icon-trash"></i>清除指令'), clean_all_machine_path(machine.id), :remote => true, :method => :put, :confirm => "确实要清除吗？")
    actions << link_to(raw('<i class="icon-retweet"></i>重连'), reconnect_machine_path(machine.id), :remote => true, :method => :put, :confirm => "重连前会断开现有连接，并中止当前指令，确实要重连吗？")
  end
end

