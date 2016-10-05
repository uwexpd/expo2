ActiveAdmin.register Scholarship do
  config.sort_order = 'title_asc'
  batch_action :destroy, false

  permit_params :title, :description, :history, :eligibility, :procedure, :contact_info, :service_agreement, :website_name, :website_url, :created, :modified, :award_amount, :freshman, :sophomore, :junior, :senior, :graduate, :disability, :male, :female, :gpa, :us_citizen, :permanent_resident, :other_visa_status, :need_based, :ethnicity, :length_of_award, :num_awards, :is_active, :resident, :non_resident, :is_national, :type_id, :page_stub, :is_incoming_student, :is_departmental, :hb_1079, :veteran, :gap_year, :graduate_school, :blurb, :fifth_year, :lgbtqi_community, scholarship_deadlines_attributes: [:id, :title, :deadline, :is_active, :_destroy], categories_attributes: [:id, :category_id, :scholarship_id, :_destroy], disabilities_attributes: [:id, :disability_id, :scholarship_id, :_destroy], ethnicities_attributes: [:id, :ethnicity_id, :scholarship_id, :_destroy], types_attributes: [:id, :type_id, :scholarship_id, :_destroy]
  
  scope :all, default: true
  scope :active
  scope :incoming
  scope :upcoming

  index do
    selectable_column
    column 'Title', sortable: :title do |scholarship|
      link_to scholarship.title, admin_scholarship_path(scholarship)
    end    
    column 'National', sortable: :is_national do |scholarship| 
        status_tag scholarship.is_national? 
    end
    column 'Active', sortable: :is_active do |scholarship| 
        status_tag scholarship.is_active? 
    end
    column "Deadlines" do |scholarship|
       scholarship.scholarship_deadlines.map{ |d| d.deadline }.compact.join("<br>").html_safe
    end
    actions
  end  
  
  show do
    tabs do
        tab 'Overview' do
          attributes_table do
              row :title         
              row :page_stub
              row (:description) {|scholarship| raw(scholarship.description) }
              row (:blurb) {|scholarship| raw(scholarship.blurb) }
              row :website_name
              row :website_url
              row (:procedure) {|scholarship| raw(scholarship.procedure) }
              row (:history) {|scholarship| raw(scholarship.history) }
              row (:service_agreement) {|scholarship| raw(scholarship.service_agreement) }
          end
        end
  
        tab 'Eligibility & Criteria' do
          attributes_table do
            row (:eligibility) {|scholarship| raw(scholarship.eligibility) }
            row :disability
            row (:gpa) {|scholarship| raw(scholarship.gpa) }
          end
          panel "Gender" do
            table_for scholarship do
                column ('Male') { |s| status_tag s.male? }
                column ('Female') { |s| status_tag s.female? }
            end               
          end      
          panel "Student Type" do
            table_for scholarship do
                column ('Freshman') { |s| status_tag s.freshman? }
                column ('Sophomore') { |s| status_tag s.sophomore? }
                column ('Junior') { |s| status_tag s.junior? }
                column ('Senior') { |s| status_tag s.senior? }
                column :fifth_year
                column ('Graduate') { |s| status_tag s.graduate? }
            end               
          end
          panel "Citizen Type" do
            table_for scholarship do
                column ('Us Citizen') { |s| status_tag s.us_citizen? }
                column ('Permanent Resident') { |s| status_tag s.permanent_resident? }
                column ('Other Visa Status') { |s| status_tag s.other_visa_status? }
                column ('Undocumented') { |s| status_tag s.hb_1079? }
            end               
          end
          panel "Resident Type" do
            table_for scholarship do
                column ('Resident') { |s| status_tag s.resident? }
                column ('Non Resident') { |s| status_tag s.non_resident? }
            end              
          end
          panel "Financial Need" do
            table_for scholarship do
                column ('Need Based') { |s| status_tag s.need_based? }
            end              
          end
          panel "Scholarship Type" do
            table_for scholarship do
                column ('Veteran') { |s| status_tag s.veteran? }
                column ('Gap Year') { |s| status_tag s.gap_year? }
                column ('Graduate School') { |s| status_tag s.graduate_school? }
                column ('LGBTQI Community') { |s| status_tag s.lgbtqi_community? }
                column ('Are offered by UW') { |s| status_tag s.is_departmental? }
                column ('Incoming Student') { |s| status_tag s.is_incoming_student? }
            end              
          end
          panel "Status Type" do
            table_for scholarship do
                column ('National') { |s| status_tag s.is_national? }
                column ('Active') { |s| status_tag s.is_active? }
            end              
          end           
        end            
        
      end # end of tabs
  end
  
  sidebar "Award Details", only: :show do
      attributes_table_for scholarship do
        row :length_of_award
        row :num_awards
        row :award_amount
      end
  end
  sidebar "Deadlines", only: :show do  
      deadlines = scholarship.scholarship_deadlines
      table_for deadlines do
        column :deadline
        column :title
      end
  end
  sidebar "Last update time", only: :show do
    attributes_table_for scholarship do
      row :updated_at
    end
  end
  
  form do |f|
    f.semantic_errors *f.object.errors.keys
    tabs do
        tab 'Basic' do             
          f.inputs 'Basic Info' do
              f.input :title, as: :string
              f.input :page_stub
              f.input :website_name        
              f.input :website_url
              f.input :description, :input_html => { :class => "tinymce", :rows => 10 }
              f.input :blurb, :input_html => { :class => "tinymce", :rows => 10 }
          end
        end
        
        tab 'Criteria' do 
           f.inputs 'Criteria Specifics' do
              f.input :disability        
              f.input :male, as: :boolean
              f.input :female, as: :boolean
              f.input :gpa
              f.input :history, :input_html => { :class => "tinymce", :rows => 10 }
              f.input :eligibility, :input_html => { :class => "tinymce", :rows => 10 }
              f.input :procedure, :input_html => { :class => "tinymce", :rows => 10 }
              f.input :service_agreement, :input_html => { :class => "tinymce", :rows => 10 }
              f.input :contact_info, :input_html => { :class => "tinymce", :rows => 10 }
           end
        end   
        
        tab 'Award' do
           f.inputs 'Award Details' do
              f.input :length_of_award
              f.input :num_awards, label: "Number of awards"
              f.input :award_amount, as: :string
           end
        end
        
        tab 'Qualifications' do                     
           f.inputs 'Student Type' do
              f.input :freshman, as: :boolean
              f.input :sophomore, as: :boolean
              f.input :junior, as: :boolean
              f.input :senior, as: :boolean
              f.input :fifth_year
              f.input :graduate, as: :boolean
           end
           f.inputs 'Citizen Type' do
              f.input :us_citizen, as: :boolean
              f.input :permanent_resident, as: :boolean
              f.input :other_visa_status, as: :boolean
              f.input :hb_1079, label: "Undocumented", as: :boolean
           end
           f.inputs 'Redisent Type' do
              f.input :resident , as: :boolean
              f.input :non_resident, as: :boolean
           end
           f.inputs 'Financial Need' do
              f.input :need_based, as: :boolean
           end
           f.inputs 'Scholarship Type' do
              f.input :veteran, as: :boolean
              f.input :gap_year, as: :boolean
              f.input :graduate_school, as: :boolean
              f.input :lgbtqi_community, as: :boolean
           end
           f.inputs 'Statu Type' do
              f.input :is_national, as: :boolean
              f.input :is_active , as: :boolean
           end
        end 
        
        tab 'Deadlines & Catgories' do
           f.has_many :scholarship_deadlines, heading: 'Deadlines', allow_destroy: true do |deadline|
              deadline.input :title, as: :string
              deadline.input :deadline, :start_year => Date.today.year - 3
              deadline.input :is_active, as: :boolean
           end        
           f.has_many :categories, heading: 'Categories', allow_destroy: true do |category|
              category.input :category_id, as: :select, :collection => Category.all
           end
        end
        
        tab 'Types & Others' do
          f.has_many :types, heading: 'Types', allow_destroy: true do |type|
             type.input :type_id, as: :select, :collection => Type.all
          end
          f.has_many :disabilities, heading: 'Disabilities', allow_destroy: true do |disability|
             disability.input :disability_id, as: :select, :collection => Disability.all
          end        
          f.has_many :ethnicities, heading: 'Ethnicities', allow_destroy: true do |ethnicity|
             ethnicity.input :ethnicity_id, as: :select, :collection => Ethnicity.all
          end
                                
        end 
                
    end
    f.actions
  end
  
  filter :title, as: :string
  filter :title_or_description_or_history_or_eligibility_cont, as: :string, label: "Keyword (title/description/history/eligibility)"
  filter :male_true, label: 'male', as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :female_true, label: 'female', as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :us_citizen_true, label: 'US Citizen', as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :permanent_resident_true, label: 'Permanent Resident', as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :other_visa_status_true, label: 'International or Other Visa Status', as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :hb_1079_true, label: 'Undocumented', as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :resident_true, label: 'resident', as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :need_based_true, label: 'Need based', as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :is_national_true, label: 'National', as: :select, collection: [["Yes", "true"], ["No", "false"]]
  
  
end
