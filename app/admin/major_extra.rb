ActiveAdmin.register MajorExtra do  
  batch_action :destroy, false
  config.sort_order = 'fixed_name_asc'  
  menu parent: 'Tools'
  config.per_page = [30, 50, 100, 200]

  permit_params :fixed_name, :chair_name, :chair_email, :discipline_category_id, :major_id

  index do
     column ('Title') {|major| link_to major.fixed_name, admin_major_extra_path(major) }     
     column ('fixed name?') {|major| status_tag major.fixed_name.present? ? "Yes" : "No"}
     column :chair_name
     column :chair_email
     column :discipline_category
     actions
  end

  show do
    attributes_table do
      row ('Name'){|major| major.fixed_name }
      row :chair_name
      row :chair_email
      row :discipline_category
    end
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      # Only show major dropdown on NEW (or if not set yet)
      if f.object.new_record?

        major_extra_major_ids = MajorExtra.all.map{|m| m.major.id unless m.major.nil?}
        majors = Major.where(major_last_yr: 9999).to_a.reject { |m| major_extra_major_ids.include?(m.id) }.sort_by(&:major_full_nm)

        f.input :major_id,
          as: :select,
          collection:  majors.map { |m| [m.major_full_nm.to_s + " (#{m.major_abbr.strip})", m.id.to_s] },
          include_blank: "Chooose a major",
          input_html: {class: 'select2'}
      else
        li class: "string input" do
          label "Major title in SDB"          
          div class: 'gray' do
            resource.major ? resource.major.major_full_nm + " (#{resource.major.major_abbr.strip})"   : "could not find major"
          end
        end        
      end
      f.input :fixed_name, :input_html => { :style => 'width:50%;' }
      f.input :chair_name
      f.input :chair_email
      f.input :discipline_category
    end
    f.actions
  end
   
  filter :fixed_name
  filter :discipline_category


  end