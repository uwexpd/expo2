ActiveAdmin.register OfferingDashboardItem, as: 'dashboard_items' do
	belongs_to :offering
	batch_action :destroy, false
	config.filters = false
	config.sort_order = 'sequence_asc'

	permit_params :disabled, :status_lookup_method, :offering_status_id, :offering_application_type_id, :criteria, :sequence, :show_group_members, :disabled, dashboard_item_attributes: [:title, :content, :css_class]

	index do		
		column ('Title') {|item| link_to item.title, admin_offering_dashboard_item_path(offering, item)}
	    column ('Creiteria') do |item|
	    	span [(item.offering_status.private_title rescue nil), 
			(item.offering_application_type.title rescue nil)].compact.join("<br>").html_safe
			span(title: "#{item.criteria}") do 
				"<br>Other Criteria".html_safe
			end unless item.criteria.blank?
	    end
	    toggle_bool_column 'Disabled', :disabled, success_message: "Successfully update the dashboard item!"   
	    actions
	end
	
	sidebar "Offering Settings" do
		render "admin/offerings/sidebar/settings", { offering: offering }
  	end

  	sidebar "Dashboard Items", only: [:show, :edit] do
		render "admin/offerings/sidebar/dashboard_items", { offering: offering, dashboard_item: dashboard_items }
  	end

  	show do
  	   attributes_table do
  	   	 row ('Item Display') do |item| 
  	   	 	b item.title
  	   	 	div item.content.html_safe rescue '#error'
  	   	 end
  	   	 row ('criteria') do |item|
  	   	 	if item.offering_status
  	   	 		div "Application must be #{item.status_lookup_method} #{item.offering_status.private_title}"
  	   	 	end
  	   	 	if item.offering_application_type
  	   	 		div "Application must be of type #{item.offering_application_type.title}"
  	   	 	end
  	   	 	if item.criteria
  	   	 		div item.criteria
  	   	 	end
  	   	 end
  	   	 row :sequence
  	   	 row :show_group_members
  	   end
  	end

  	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  f.inputs for: :dashboard_item do |item_form|
	  	item_form.input :title
	  	item_form.input :content, as: :text, input_html: { class:  "tinymce", rows: 8 }
	  	# input_html: { rows: 5, style: 'width: 100%'}
	  	item_form.input :css_class, label: 'Style', input_html: { style: 'width: 50%'}, hint: "You can include multiple CSS classes here, separated by spaces."
	  end
	  f.inputs do	  	
	  	div "Creiteria", class: 'label'
	  	columns do
           column max_width: "130px", min_width: "130px" do
              para "Application must be"
           end
           column max_width: "90px" do
              f.input :status_lookup_method, label: false, as: :select, collection: { "currently in" => 'in_status?', "in or past" => 'passed_status?' }, include_blank: false
           end
           column max_width: "67px" do
              para "this status"
           end
           column do 
           	  f.input :offering_status_id, label: false, as: :select, collection: offering.statuses.sort.map{|s|[s.private_title, s.id]}, include_blank: true
           end
        end
        columns do
          column max_width: "205px", min_width: "205px" do
              para "Application must be of this type:"
          end
          column do
              f.input :offering_application_type_id, label: false, as: :select, collection: offering.application_types.sort.map{|a|[a.title, a.id]}, include_blank: true
           end
        end
	  	
	  	f.input :criteria, label: 'Other Criteria', input_html: { rows: 3, style: 'width: 100%'}, hint:	"This bit of code defines who sees this dashboard item. 
			Use the <tt>object</tt> variable to access the ApplicationForOffering or 
			ApplicationGroupMember object (depending on who is logged in).".html_safe
	  	f.input :sequence
	  	f.input :show_group_members, hint: 'Leave this box unchecked if only primary applicants should see this item on their dashboards.'
	  	f.input :disabled, hint: 'Disabled dashboard items are never displayed to any users.'
	  end
	  actions
	end
  	
end