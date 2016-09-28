ActiveAdmin.register Scholarship do
  config.sort_order = 'title_asc'

  permit_params :title, :description, :history, :eligibility, :procedure, :contact_info, :service_agreement, :website_name, :website_url, :created, :modified, :award_amount, :freshman, :sophomore, :junior, :senior, :graduate, :disability, :male, :female, :gpa, :us_citizen, :permanent_resident, :other_visa_status, :need_based, :ethnicity, :length_of_award, :num_awards, :is_active, :resident, :non_resident, :is_national, :type_id, :page_stub, :is_incoming_student, :is_departmental, :hb_1079, :veteran, :gap_year, :graduate_school, :blurb, :fifth_year, :lgbtqi_community
  
  # Create sections on the index screen
  scope :all, default: true
  scope :active
  scope :incoming
  scope :upcoming

  # Customize columns displayed on the index screen in the table
  index do
    selectable_column
    column "Title", sortable: :title do |scholarship|
      link_to scholarship.title, admin_scholarship_path(scholarship)
    end    
    column "National", :is_national
    column "Active", :is_active
    actions
  end
  
  # Add for tinymce
  form do |f|
      f.inputs do      
        inputs 'Basic Info' do
          f.input :title, as: :string
          f.input :page_stub
          f.input :description, :input_html => { :class => "tinymce", :rows => 10 }
          f.input :blurb, :input_html => { :class => "tinymce", :rows => 10 }
        end
        inputs 'Criteria Specifics' do
          f.input :disability        
          f.input :male
          f.input :female
          f.input :gpa
          f.input :history, :input_html => { :class => "tinymce", :rows => 10 }
          f.input :eligibility, :input_html => { :class => "tinymce", :rows => 10 }
          f.input :procedure, :input_html => { :class => "tinymce", :rows => 10 }
          f.input :service_agreement, :input_html => { :class => "tinymce", :rows => 10 }
          f.input :contact_info, :input_html => { :class => "tinymce", :rows => 10 }
        end
        inputs 'Web Site' do
          f.input :website_name        
          f.input :website_url
        end
        inputs 'Award Details' do
          f.input :length_of_award
          f.input :num_awards, label: "Number of awards"
          f.input :award_amount, as: :string
        end
        panel 'Qualifications' do
          inputs 'Student Type' do
            f.input :freshman, as: :boolean
            f.input :sophomore, as: :boolean
            f.input :junior, as: :boolean
            f.input :senior, as: :boolean
            f.input :fifth_year
            f.input :graduate, as: :boolean
          end
          inputs 'Citizen Type' do
            f.input :us_citizen, as: :boolean
            f.input :permanent_resident, as: :boolean
            f.input :other_visa_status, as: :boolean
            f.input :hb_1079, label: "Undocumented", as: :boolean
          end
          inputs 'Redisent Type' do
            f.input :resident , as: :boolean
            f.input :non_resident, as: :boolean
          end
          inputs 'Financial Need' do
            f.input :need_based, as: :boolean
          end
          inputs 'Scholarship Type' do
            f.input :veteran, as: :boolean
            f.input :gap_year, as: :boolean
            f.input :graduate_school, as: :boolean
            f.input :lgbtqi_community, as: :boolean
          end
          inputs 'Statu Type' do
            f.input :is_national, as: :boolean
            f.input :is_active , as: :boolean
          end
        end 

      end
      f.actions
  end
  
  # Filterable attributes on the index screen
  filter :title, as: :string
  filter :title_or_description_or_history_or_eligibility_cont, as: :string, label: "Keyword (title/description/history/eligibility)"
  filter :disability, as: :string
  filter :male_true, label: "male", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :female_true, label: "female", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :us_citizen_true, label: "US Citizen", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :permanent_resident_true, label: "Permanent Resident", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :other_visa_status_true, label: "International or Other Visa Status", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :hb_1079_true, label: "Undocumented", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :resident_true, label: "resident", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :non_resident_true, label: "non_resident", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :need_based_true, label: "need_based", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :is_national_true, label: "is_national", as: :select, collection: [["Yes", "true"], ["No", "false"]]

  
  
  
end
