ActiveAdmin.register OfferingApplicationCategory, as: 'application_category' do
  belongs_to :offering
  menu false
  batch_action :destroy, false
  config.filters = false
  config.sort_order = 'id_asc'
  config.per_page = [50, 100, 200]

  permit_params :application_category_id, :other_option, :offering_application_type_id, :sequence

  index do 
    column ('Category') {|category| link_to category.title, admin_offering_application_category_path(offering, category) rescue "unknown" }
    column ('Type') {|category| category.offering_application_type.title if category.offering_application_type }
    column ('Other Option?') {|category| category.other_option }    
    column ('Sequence') {|category| category.sequence }
    actions
  end

  show :title => proc{|category| category.title.html_safe rescue 'EMPTY' }  do
    attributes_table do
      row ('Category'){|category| category.title rescue 'EMPTY' }
      row ('Type'){|category| category.offering_application_type.title rescue 'EMPTY' }
      row ('Other Option'){|category| category.other_option }
      row ('sequence'){|category| category.sequence }      
    end    
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :application_category_id, required: true, as: :select, collection: ApplicationCategory.all.sort, include_blank: 'Please select', input_html: { class: "select2" }
      f.input :offering_application_type_id, required: true, as: :select, collection: offering.application_types.all.sort, include_blank: 'Please select'
      f.input :other_option, hint: 'This option acts as an "other" option where users can type in a custom answer.'
      f.input :sequence, input_html: { style: 'width: 20%;' }
    end
    f.actions
   end

  sidebar "Offering Settings" do
    render "admin/offerings/sidebar/settings", { offering: offering }
  end

  # filter :offering_application_type_id, as: :select, colleciton: ApplicationType.all

end