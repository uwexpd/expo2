ActiveAdmin.register OfferingApplicationType, as: 'application_type' do
  belongs_to :offering
  menu false
  batch_action :destroy, false
  config.filters = false
  config.sort_order = 'id_asc'

  permit_params :application_type_id, :allow_other_category, :workshop_event_id, :description

  index do 
  	column ('Appliation Type') {|type| link_to type.title, admin_offering_application_type_path(offering, type) }
    column ('Offering') {|type| offering.name }
    column ('Allow Other Category'.html_safe) {|type| type.allow_other_category }    
    column ('Workshop Event') {|type| type.workshop_event.title if type.workshop_event }
    actions
  end

  show :title => proc{|type| type.title.html_safe} do
    attributes_table do
      row ('Application type'){|type| (type.title + " <span class='caption'>(#{object_timestamp_details(type)})</span>").html_safe }
      row ('Offering'){|type| offering.name }
      row ('Allow Other Category'){|type| type.allow_other_category }
      row ('Workshop Evente'){|type| type.workshop_event }
      row ('Description'){|type| type.description }
    end    
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :application_type_id, as: :select, collection: ApplicationType.all.sort
      f.input :allow_other_category, hint: 'This option acts as an "other" option where users can type in a custom answer.'
      f.input :workshop_event_id, as: :select, collection: Event.order(id: :desc), include_blank: 'Select a workshop (Optional)', input_html: { class: "select2", style: 'width: 100%' }, hint: "or #{ link_to "Create one", new_admin_event_path(offering_id: offering), target: '_blank' }".html_safe
      f.input :description, as: :text, input_html: {rows: 5}
    end    
    f.actions
   end

  sidebar "Offering Settings" do
    render "admin/offerings/sidebar/settings", { offering: offering }
  end


end