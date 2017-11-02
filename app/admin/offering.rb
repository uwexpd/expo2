ActiveAdmin.register Offering do    
  batch_action :destroy, false  
  menu label: "OnlineApps"  
  config.sort_order = '' # Use blank to override the default sort by id in activeadmin
  scope 'All', :sorting, default: true
  menu parent: 'Modules'
    
  index do
    column ('Name') {|offering| link_to(offering.name, admin_offering_path(offering)) }
    column ('Unit') {|offering| link_to(offering.unit.abbreviation, admin_unit_path(offering.unit)) if offering.unit }
    column ('Quarter') {|offering|  offering.quarter_offered ? offering.quarter_offered.title : offering.year_offered }
    column ('Current Phase') {|offering| offering.current_offering_admin_phase.name rescue nil }
    column ('Applications') {|offering| "#{offering.application_for_offerings_count.to_s} Apps" unless offering.application_for_offerings_count.nil? }
    actions
  end
  
  show do
    attributes_table do
      row :name
      row :unit
    end
  end
  
  sidebar "More Settings", only: :show do  
     
  end
  
  form do |f|
    f.semantic_errors *f.object.errors.keys
    tabs do
      tab 'Main Details' do 
        f.inputs 'Main Details' do
          f.input :name, as: :string
          div 'The official name of this offering. This will automatically be combined with the quarter or year
      			of the offering. Example: Entering "Mary Gates Leadership Scholarship" will be displayed as "Mary Gates Leadership
      			Scholarship Autumn 2008" when displayed in lists.', class: 'caption'
          f.input :unit,  as: :select, required: true
          f.input :open_date, as: :datetime_picker, :input_html => { :style => "width:50%;" }
          f.input :deadline, as: :datetime_picker, :input_html => { :style => "width:50%;" }
          f.input :description, :input_html => { :class => "tinymce", :rows => 6 }
          div 'Displayed in public listings of available offerings when a student logs in.', class: 'caption'
          f.input :contact_name
          div 'This contact information is displayed in error messages and other messages.', class: 'caption'
          f.input :contact_email
          f.input :contact_phone
          f.input :notify_email, label: 'Notifications email'
          div 'Where should notifications of submitted applications go? Separate multiple email addresses with commas.', class: 'caption'
          f.input :quarter_offered_id, as: :select, collection: Quarter.all.select{|q|q.year > 1994}.map{|q| [q.title, q.id]}, include_blank: true
          f.input :year_offered, as: :select, collection: 1995..Time.now.year+5, include_blank: true
          div 'Specify a year instead of a quarter if this offering spans more time or only happens annually.', class: 'caption'
          f.input :destroy_by
          div 'This date is added to the top of pages when printed or converted to PDF.', class: 'caption'
          f.input :notes, :input_html => { :rows => 3, :style => "width:100%;" }
          div 'Use this space to track internal notes about this offering.', class: 'caption'
        end
        f.inputs 'Accountability Settings' do
          div 'If students from this application process should be included in accountability data, change these settings to
          	control the way that applications will be counted.', class: 'intro'
          f.input :activity_type_id, as: :select, collection: ActivityType.all, :include_blank => "Do not include in accountability reports"
          div 'Choose the type of activity that this work is eligible to be counted for.', class: 'caption'
        end
      end            
    end
    f.actions
  end
  
  filter :name, as: :string
  filter :open_date, as: :date_range
  filter :deadline, as: :date_range
  filter :unit_id, as: :select, collection: Unit.all.pluck(:abbreviation, :id)

end