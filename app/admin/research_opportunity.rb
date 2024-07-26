ActiveAdmin.register ResearchOpportunity do
  batch_action :destroy, false
  config.sort_order = 'submitted_at_desc'
  menu parent: 'Databases', priority: 30, label: "<i class='mi padding_right'>school</i> Research Opportunities".html_safe

  permit_params :name, :email, :department, :title, :description, :requirements, :research_area1, :research_area2, :research_area3, :research_area4, :end_date, :active, :removed, :submitted, :submitted_at, :submitted_person_id, :paid, :work_study, :location, :learning_benefit
  
  member_action :email_queue, :method => :put do
    @opportunity = ResearchOpportunity.find(params[:id])
    @opportunity.reload
    # logger.debug "Debug active => #{@opportunity.active?}"
    template_name = @opportunity.active? ? "research opportunity activate notification for faulty" : "research opportunity deactivate notification for faulty"
    faculty_template = EmailTemplate.find_by_name(template_name)
    link = "https://#{Rails.configuration.constants['base_app_url']}/opportunities/submit/#{@opportunity.id}"

    if faculty_template
      EmailQueue.queue(nil, faculty_template.create_email_to(@opportunity, link, @opportunity.email).message)
    else
      redirect_to admin_research_opportunity_path(@opportunity.id), notice: "Something went wrong and not able to queue email to faculty"
    end

    redirect_to admin_research_opportunity_path(@opportunity.id), notice: "Successfully queued an e-mail to  #{@opportunity.name}"
  end  

  index do
     column ('Title') {|opportunity| link_to opportunity.title, admin_research_opportunity_path(opportunity.id)}
     column 'Active', sortable: :active do |opportunity| 
        status_tag opportunity.active?, class: 'small'
     end
     # toggle_bool_column 'Active', :active, success_message: "Successfully update research opportunity status!"
     # toggle_bool_column 'Removed', :removed, success_message: "Research opportunity updated removed field successfully!"     
     column 'Submit Date', sortable: :submitted_at do |opportunity|
       opportunity.submitted_at.strftime("%F") if opportunity.submitted_at
     end
     column 'Auto-remove Date', sortable: :end_date do |opportunity| 
       opportunity.end_date.strftime("%F") if opportunity.end_date
     end
    actions
  end
   
  show :title => proc{|opportunity|opportunity.title} do
    tabs do
      tab 'Overview' do
        attributes_table do
          row :title
          row ('Contact Name'){|opportunity| opportunity.name}
          row ('Contact Email'){|opportunity| opportunity.email}
          row ('Department/Other Affiliation'){|opportunity| opportunity.department}
          row ('Description'){|opportunity| raw(opportunity.description)}
          row ('Student Learning Benefit'){|opportunity| raw(opportunity.learning_benefit)}
          row ('Minimum Requirements'){|opportunity| raw(opportunity.requirements) } 
        end
      end
      tab 'Area & More' do
          attributes_table do
            row ('Auto-remove date'){|opportunity| opportunity.end_date.try(:to_date) }
            row ('Research Area 1'){|opportunity| ResearchArea.find(opportunity.research_area1).name if opportunity.research_area1 && opportunity.research_area1 > 0}
            row ('Research Area 2'){|opportunity| ResearchArea.find(opportunity.research_area2).name if opportunity.research_area2 && opportunity.research_area2 > 0}
            row ('Research Area 3'){|opportunity| ResearchArea.find(opportunity.research_area3).name if opportunity.research_area3 && opportunity.research_area3 > 0}
            row ('Research Area 4'){|opportunity| ResearchArea.find(opportunity.research_area4).name if opportunity.research_area4 && opportunity.research_area4 > 0}
            row :submitted
            row ('Submitted At'){|opportunity| opportunity.submitted_at}
            row ('Submitted Person'){|opportunity| opportunity.submitted_person}
            row :paid
            row :work_study
            row :location
          end
      end
    end              
  end

  sidebar "Status", only: [:show, :edit] do
      # attributes_table_for research_opportunity do
      #   row :active
      #   row :removed        
      # end
      render 'status', { opportunity: research_opportunity }
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    tabs do
      tab 'basic info' do
        f.inputs do
          f.input :title, required: true
          # f.input :active, label: 'Active?', as: :boolean      
          f.input :name, label: 'Contact Name', required: true
          f.input :email, label: 'Contact Email', required: true
          f.input :department, label: 'Department/Other Affiliation', required: true    
          f.input :description, label: 'Description', required: true, :input_html => { class: "tinymce", rows: 15}
          f.input :learning_benefit, label: 'Student Learning Benefit', required: true, :input_html => { class: "tinymce", rows: 15}
          f.input :requirements, label: 'Minimum Requirements', required: true, :input_html => { class: "tinymce", rows: 15 }          
        end
      end
      tab 'area & more' do
        f.inputs do
          f.input :active, as: :boolean
          f.input :end_date, label: 'Auto-remove date', as: :datepicker, required: true, :input_html => { :style => 'width:50%;' }
          f.input :research_area1, as: :select, collection: ResearchArea.all.collect{|a|[ a.name, a.id ]}.sort, required: true, input_html: { class: "select2", :style => 'width:50%;' }
          f.input :research_area2, as: :select, collection: ResearchArea.all.collect{|a|[ a.name, a.id ]}.sort, input_html: { class: "select2", :style => 'width:50%;' }
          f.input :research_area3, as: :select, collection: ResearchArea.all.collect{|a|[ a.name, a.id ]}.sort, input_html: { class: "select2", :style => 'width:50%;' }
          f.input :research_area4, as: :select, collection: ResearchArea.all.collect{|a|[ a.name, a.id ]}.sort, input_html: { class: "select2", :style => 'width:50%;' }
          f.input :submitted, as: :boolean
          f.input :submitted_at, as: :datetime_picker, required: true
          f.input :submitted_person_id, label: "Submitted EXPO Person ID"
          f.input :paid, as: :boolean
          f.input :work_study, as: :boolean
          f.input :location, as: :select, collection: ['UW Seattle', 'UW Bothell', 'UW Tacoma', 'Off campus – South Lake Union', 'Off campus – Fred Hutch Cancer Research Center', 'Off campus – Seattle Children’s', 'Off campus – Other']
        end
      end
    end
    f.actions
  end
   
  filter :title, as: :string
  # filter :research_area1_or_research_area2_or_research_area3_or_research_area4_in, as: :select, label: "Discipline Search", collection: ResearchArea.order(:name), input_html: { class: 'chosen-select', multiple: true}
  filter :research_area1_or_research_area2_or_research_area3_or_research_area4_in, as: :select, label: "Discipline", collection: ResearchArea.order(:name).pluck(:name, :id), input_html: { class: "select2", multiple: 'multiple'}
  filter :title_or_department_or_description_cont, as: :string, label: "Keyword (title, department, and description)"
  filter :name_or_email_or_description_cont, as: :string, label: "Research Mentor/Contact (name, email, and description)"
  filter :active, as: :boolean
  # filter :removed, as: :boolean
  filter :paid, as: :boolean
  filter :work_study, as: :boolean
  filter :location, as: :select, collection: ['UW Seattle', 'UW Bothell', 'UW Tacoma', 'Off campus – South Lake Union', 'Off campus – Fred Hutch Cancer Research Center', 'Off campus – Seattle Children’s', 'Off campus – Other']
  filter :submitted_at, label: 'Submit Date', as: :date_range
  filter :end_date, label: 'End Date (auto-remove)', as: :date_range

end