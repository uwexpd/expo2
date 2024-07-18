module ActiveAdmin
  module Views
    class IndexAsTable < ActiveAdmin::Component
      # include CustomHelper

      def editable_text_column resource, model_name, attr, required, url
        val = resource.send(attr)
        val = "&nbsp;" if val.blank?

        html = %{
                  <div  id="editable_text_column_#{resource.id}_#{attr}"
                        class="editable_text_column tooltip noborder" 
                        title="Double click to edit and press enter to save"
                        ondblclick="admin.editable_text_column_do(this)" >
                        #{val}
                   </div>
                   
                   <input 

                      data-path="#{resource.class.name.tableize}"
                      data-model="#{model_name}"
                      data-attr="#{attr}"
                      data-resource-id="#{resource.id}"
                      data-required="#{required}"
                      data-url = "#{url}"
                      class="editable_text_column admin-editable"
                      id="editable_text_column_#{resource.id}_#{attr}"

                      style="display:none;" />
              }
        html.html_safe
      end

      # def column_select resource, model_name, attr, list
      #   val = resource.send(attr)

      #   html = _select list, val, { "attrs" => %{
      #                                               data-path="#{resource.class.name.tableize}"
      #                                               data-model="#{model_name}"
      #                                               data-attr="#{attr}"
      #                                               data-resource-id="#{resource.id}"
      #                                               class="admin-selectable"
      #                                           } 
      #                             }
      #   html.html_safe
      # end


    end
  end
end