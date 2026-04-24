ActiveAdmin.register DisciplineCategory do
  batch_action :destroy, false
  config.sort_order = 'name_asc'  
  menu parent: 'Tools'
  
  permit_params :name
  
  index do
     column ('Name') {|dc| link_to dc.name, admin_discipline_category_path(dc) }
     column ('Associated Majors') {|dc| dc.majors.size }
     actions
  end
   
  show do
    attributes_table do
      row :name
      row ('Associated Majors'){|dc| dc.majors.size}
    end
    panel '' do
      div class: "content-block" do
        table_for resource.major_extras.order(:fixed_name), id: "majors_table" do
          column("Title") do |major_extra|
            major_extra.major&.title.presence ||
              major_extra.fixed_name.presence ||
              major_extra.id
          end

          column("Has fixed name?") do |major_extra|
            major_extra.fixed_name.present? ? "Yes" : "No"
          end

          column("Edit") do |major_extra|
            link_to "Edit", edit_admin_major_extra_path(major_extra)            
          end

          column("Remove from category") do |major_extra|
            link_to "Remove",
              admin_major_extra_path(major_extra, major_extra: { discipline_category_id: nil }),
              method: :patch,
              data: { confirm: "Are you sure you want to remove this major from this discipline category?" }
          end
        end

        if resource.majors.empty?
          div class: "empty" do
            "No majors are associated with this category."
          end
        end
      end
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do  
      f.input :name, :input_html => { :style => 'width:50%;' }      
    end
    f.actions
  end
   
  filter :name
  
end