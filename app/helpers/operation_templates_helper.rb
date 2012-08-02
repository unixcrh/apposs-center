# coding: utf-8
module OperationTemplatesHelper
  def draggable_item d_template,checked
    raw %Q{
      <i class="icon-minus-sign" onclick="$(this).parent().remove()" />
      #{d_template.alias || d_template.name}
      <input type="hidden"
        name="operation_template[source_ids][]" 
        value="#{d_template.id}|#{checked}" />
    }
  end
end
