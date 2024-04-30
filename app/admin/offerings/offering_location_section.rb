ActiveAdmin.register OfferingLocationSection, as: 'location_sections' do
  belongs_to :offering
  menu false
  batch_action :destroy, false
  config.filters = false
  config.sort_order = 'id_asc'

  permit_params :title, :starting_easel_number, :ending_easel_number, :color

  index do 
  	column ('Title') {|section| link_to section.title, admin_offering_location_section_path(offering, section) }
    column ('Starting Easel Number') {|section| section.starting_easel_number }
    column ('Ending Easel Number'.html_safe) {|section| section.ending_easel_number }    
    column ('Color') {|section| span section.color, style: "background-color: #{section.color.include?('#') ? section.color : '#'+section.color};", class: 'section_color' }
    actions
  end

  show do
    attributes_table do
      row ('Offering'){|section| offering.name }
      row ('Title'){|section| section.title }
      row ('Easel Range'){|section| section.starting_easel_number.to_s + ' - ' + section.ending_easel_number.to_s }
      row ('Color'){|section| span section.color, style: "background-color: #{section.color.include?('#') ? section.color : '#'+section.color};", class: 'section_color' }
    end    
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :title
      f.input :starting_easel_number, label: 'Easels From'
      f.input :ending_easel_number, label: 'To'
      f.input :color, as: :color, hint: 'Click in text box to choose a color or enter in a color value', input_html: { style: "background-color: #{f.object.color}; padding: 1.25rem; width: 25%"}
    end
    f.actions
   end

  sidebar "Offering Settings" do
    render "admin/offerings/sidebar/settings", { offering: offering }
  end


end