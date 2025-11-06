ActiveAdmin.register ServiceLearningCourse do
  batch_action :destroy, false
  config.sort_order = 'id_desc'
  config.per_page = [30, 50, 100, 200, 300]
  menu parent: 'Tools'  

  # scope "#{Quarter.current_quarter.title}", :current_quarter, default: true
  index do     
     column ('Title') {|course| link_to raw(course.alternate_title), admin_service_learning_course_path(course) }
     column ('Quarter') {|course| course.quarter.title}
     column ('Class size') {|course| course.enrollee_count rescue "(error occurred)"}
     column :required
     column :unit
     actions
  end

  show do
    attributes_table do
      row ('Courses') {|course| span status_tag course.courses.collect(&:abbrev).join(', '), class: 'highlight'}
      row ('Title') do |course|
        span raw course.title
        span status_tag course.quarter.title, class: 'small'
      end
      row :overview
      row :syllabus
      row :syllabus_url
      row :role_of_service_learning
      row :assignments      
    end    
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do  
      f.input :alternate_title
      f.input :quarter
      # f.input :syllabus, as: :file
      f.input :syllabus_url
      f.input :overview, as: :text, input_html: { class: "tinymce", rows: 3 }
      f.input :role_of_service_learning, as: :text, input_html: { class: "tinymce", rows: 3 }
      f.input :assignments, as: :text, input_html: { class: "tinymce", rows: 3 }
    end
    f.actions
  end

  filter :alternate_title
  filter :quarter, as: :select, input_html: { class: "select2", multiple: 'multiple'}
  filter :unit, as: :select, input_html: { class: "select2", multiple: 'multiple'}


end