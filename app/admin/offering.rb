ActiveAdmin.register Offering do    
  batch_action :destroy, false  
  menu label: "OnlineApps"  
  config.sort_order = '' # Use blank to override the default sort by id in activeadmin
  scope 'All', :sorting, default: true
    
  index do
    column :name
    column ('Unit') {|offering| link_to(offering.unit.abbreviation, admin_unit_path(offering.unit)) if offering.unit }
    column ('Quarter') {|offering|  offering.quarter_offered ? offering.quarter_offered.title : offering.year_offered }
    column ('Current Phase') {|offering| offering.current_offering_admin_phase.name rescue nil }
    column ('Applications') {|offering| "#{offering.application_for_offerings_count.to_s} Apps" unless offering.application_for_offerings_count.nil? }
    actions
  end
  
  filter :name, as: :string
  filter :open_date, as: :date_range
  filter :deadline, as: :date_range
  filter :unit_id, as: :select, collection: Unit.all.pluck(:abbreviation, :id)

end