ActiveAdmin.register ServiceLearningPosition do  
  batch_action :destroy, false
  config.sort_order = 'title'
  config.per_page = [30, 50, 100, 200, 300]
  menu parent: 'Tools'
  
  scope "#{Quarter.current_quarter.title}", :current_quarter, default: true
  scope "All", :sorting

  permit_params :title, :organization_quarter_id
  
  index do     
     column ('Title') {|position| link_to raw(position.title), admin_service_learning_position_path(position) }
     column ('Organization') {|position| position.organization.title }
     column ('Filled') {|position| position.filled_placements_count}
     column ('Total') {|position| position.total_placements_count}
     column ('Unallocated') {|position| position.unallocated_placements_count}
     if params[:scope] == "all"
       column ('Quarter') {|position| status_tag position.organization_quarter.title, class: 'small'}
     end 
     column :unit
     actions
  end   
   
  show do
    attributes_table do
      row ('Title') do |position|
        span raw position.title
        span status_tag position.organization_quarter.title, class: 'small'
      end
      row ('Organization') {|position| position.organization.title}
      row ('Context'){|position| raw position.context_description}
      row ('Description'){|position| raw position.description}
      row ('Impact'){|position| raw position.impact_description}
      row ('supervisor') do |position|
        sp = position.supervisor.person
        div link_to sp.fullname, admin_person_path(sp) rescue nil
        div sp.email
        div phone_number(sp.phone.to_i) rescue nil
      end
      row ('location') do |position|
        div position.location.title rescue "None"
        div raw address_block(position.location)
      end
      if resource.location
        location = resource.location
        unless location.driving_directions.blank?
          row ('driving notes') {|position| simple_format(position.location.driving_directions)}
        end
        unless location.bus_directions.blank?
          row ('bus notes') {|position| simple_format(position.location.bus_directions)}
        end
        unless location.notes.blank?
          row ('notes') {|position| simple_format(position.location.notes)}
        end
      end
      unless resource.alternate_transportation.blank?
        row ('alt. transportation') {|position| position.location.alternate_transportation}
      end
      row ('Requirements') do |position|
        div "Must be #{position.age_requirement} #{'('+position.other_age_requirement+')' if position.has_other_age_requirement? && position.other_age_requirement} years old" unless position.age_requirement.blank?
        div "Must commit for #{position.duration_requirement}" unless position.duration_requirement.blank?
        div "TB test required" if position.tb_test_required?
        div "Flu vaccination required<br>" if position.flu_vaccination_required? 
        div "Valid food handler’s permit required" if position.food_permit_required?
        div "Other health screenings or certifications required: #{position.other_health_requirement if position.other_health_requirement}" if position.other_health_required?
        div "Other paperwork: #{position.paperwork_requirement}" unless position.paperwork_requirement.blank?
        if position.background_check_required?
          b "Background check required"
          div class: "left-indent" do
            div "Full legal name required" if position.legal_name_required?
            div "Birthdate required" if position.birthdate_required?
            div "Social security number required" if position.ssn_required?
            div "Fingerprinting  required" if position.fingerprint_required?
            div  "Other background required: #{position.other_background_check_requirement if position.other_background_check_requirement}" if position.other_background_check_required?
            div "This site is not able to accommodate international students, due to the length of time and cost required to complete international background checks<br>" if position.non_intl_student_required?
          end
        end
      end
    end
  end

  sidebar "Placements", only: :show do
    ul do
      li raw "Ideal number of students: <strong> #{service_learning_position.ideal_number_of_slots}</strong>" || "&Oslash;"
      klass = "red" if service_learning_position.placements.count < service_learning_position.ideal_number_of_slots rescue nil
      li raw "Number of slots created: <strong class= '#{klass}'>#{service_learning_position.placements.count}</strong>"      
      li raw "Students placed: #{service_learning_position.placements.filled.size}"
    end
    table_for service_learning_position.placements.where.not(person_id: nil).sort_by { |p| p.person&.fullname || '' } do
       column ('Fullname'){|placement| link_to placement.person.fullname, placement.person.is_a?(Student) ? admin_student_path(placement.person) : admin_person_path(placement.person)}
       column ('Course'){|placement| placement.course.title }
       # link_to truncate(placement.course.title, 12), service_learning_course_path(@unit, @quarter, placement.course),:title => placement.course.title unless placement.course.nil?       
    end
    
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do  
      f.input :title
      f.input :description, :input_html => { :rows => 3 }
    end
    f.actions
  end
   
  filter :title  
  filter :organization_quarter_quarter_id, label: 'Quarter', as: :select, collection: (Quarter.current_and_future_quarters(3) + Quarter.past_quarters(60)).sort.reverse!.map{|a|[a.title, a.id]}, input_html: { class: "select2", multiple: 'multiple'}
  filter :organization_quarter_organization_name, as: :string, label: 'Organization'
  filter :unit, input_html: { class: 'select2', multiple: 'multiple'}
  
  
end