ActiveAdmin.register OfferingOtherAwardType, as: 'other_award_types' do
  belongs_to :offering
  menu false
  batch_action :destroy, false
  config.filters = false
  config.sort_order = 'id_asc'

  permit_params :award_type_id, :ask_for_award_quarter, :restrict_number_of_awards_to

  index do 
  	column ('Award Type') {|other_award| link_to other_award.award_type.try(:title), admin_offering_other_award_type_path(offering, other_award) }
    column ('Ask For Award Quarter') {|other_award| other_award.ask_for_award_quarter }
    column ('Restrict Number Of Awards To') {|other_award| other_award.restrict_number_of_awards_to }    
    actions
  end

  show do
    attributes_table do      
      row ('Offering'){|other_award| offering.name }
      row ('Award type'){|other_award| other_award.award_type.try(:title) }
      row ('Ask For Award Quarter'){|other_award| other_award.ask_for_award_quarter }
      row ('Restrict Number Of Awards To'){|other_award| other_award.restrict_number_of_awards_to }      
    end    
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :award_type_id, as: :select, collection:  AwardType.all.sort
      f.input :ask_for_award_quarter
      f.input :restrict_number_of_awards_to
    end
    f.actions
   end

  sidebar "Offering Settings" do
    render "admin/offerings/sidebar/settings", { offering: offering }
  end


end