ActiveAdmin.register ResearchOpportunity do
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu parent: 'Tools'

  permit_params :name, :email, :department, :title, :description, :requirements, :research_area1, :research_area2, :research_area3, :research_area4, :end_date, :active, :removed, :submitted
  
  index do
     column ('Title') {|opportunity| link_to opportunity.title, admin_research_opportunity_path(opportunity.id)}
     column 'Active', sortable: :active do |opportunity| 
        status_tag opportunity.active?, class: 'small'
     end
     toggle_bool_column 'Removed', :removed, success_message: "Research opportunity updated successfully!"
     # column 'Removed', sortable: :removed do |opportunity| 
     #    status_tag opportunity.removed?, class: 'small'
     # end
     column 'Submit Date', sortable: :created_at do |opportunity|
       opportunity.created_at.strftime("%F")
     end
    actions
  end
   
  show :title => proc{|opportunity|opportunity.title} do
    attributes_table do
      row :title
      row ('Contact Name'){|opportunity| opportunity.name}
      row ('Contact Email'){|opportunity| opportunity.email}
      row ('Department/Other Affiliation'){|opportunity| opportunity.department}
      row ('Description'){|opportunity| raw(opportunity.description)}
      row ('Minimum Requirements'){|opportunity| raw(opportunity.requirements) } 
      row ('Auto-remove date'){|opportunity| opportunity.end_date.try(:to_date) }
      row ('Research Area 1'){|opportunity| ResearchArea.find(opportunity.research_area1).name if opportunity.research_area1}
      row ('Research Area 2'){|opportunity| ResearchArea.find(opportunity.research_area2).name if opportunity.research_area2}
      row ('Research Area 3'){|opportunity| ResearchArea.find(opportunity.research_area3).name if opportunity.research_area3}
      row ('Research Area 4'){|opportunity| ResearchArea.find(opportunity.research_area4).name if opportunity.research_area4}
    end
  end

  sidebar "Status", only: :show do
      attributes_table_for research_opportunity do
        row :active
        row :removed        
      end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :title, required: true
      # f.input :active, label: 'Active?', as: :boolean      
      f.input :name, label: 'Contact Name', required: true
      f.input :email, label: 'Contact Email', required: true
      f.input :department, label: 'Department/Other Affiliation', required: true
      f.input :removed, label: 'Removed?', as: :boolean
      f.input :description, label: 'Description', required: true, :input_html => { :class => "tinymce", :rows => 10 }
      f.input :requirements, label: 'Minimum Requirements', required: true, :input_html => { :class => "tinymce", :rows => 10 }
      f.input :end_date, label: 'Auto-remove date', as: :datepicker, required: true, :input_html => { :style => 'width:50%;' }
      f.input :research_area1, as: :select, collection: ResearchArea.all.collect{|a|[ a.name, a.id ]}.sort, required: true, input_html: { class: "select2" }
      f.input :research_area2, as: :select, collection: ResearchArea.all.collect{|a|[ a.name, a.id ]}.sort, input_html: { class: "select2" }
      f.input :research_area3, as: :select, collection: ResearchArea.all.collect{|a|[ a.name, a.id ]}.sort, input_html: { class: "select2" }
      f.input :research_area4, as: :select, collection: ResearchArea.all.collect{|a|[ a.name, a.id ]}.sort, input_html: { class: "select2" }
    end
    f.actions
  end
   
  filter :title, as: :string
  filter :title_or_department_or_description_cont, as: :string, label: "Keyword (title, department, and description)"
  filter :name_or_email_or_description_cont, as: :string, label: "Research Mentor/Contact (name, email, and description)"
  filter :active, as: :boolean
  filter :removed, as: :boolean
  filter :created_at, label: 'Submit Date', as: :date_range


end