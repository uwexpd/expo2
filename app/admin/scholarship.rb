ActiveAdmin.register Scholarship do
  config.sort_order = 'title_asc'

  # Create sections on the index screen
  # scope :all, default: true
  # scope :available
  # scope :drafts

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
        f.input :title, as: :string
        f.input :description, :input_html => { :class => "tinymce", :rows => 10 }
        f.input :history, :input_html => { :class => "tinymce", :rows => 10 }
        f.input :eligibility, :input_html => { :class => "tinymce", :rows => 10 }
        f.input :procedure, :input_html => { :class => "tinymce", :rows => 10 }
        f.input :contact_info, :input_html => { :class => "tinymce", :rows => 10 }
        f.input :service_agreement, :input_html => { :class => "tinymce", :rows => 10 }
        f.input :website_name        
        f.input :website_url
        f.input :award_amount, as: :string
        f.input :disability

      end
  end
  
  # Filterable attributes on the index screen
  filter :title, as: :string
  filter :title_or_description_or_history_or_eligibility_cont, as: :string, label: "Keyword (title/description/history/eligibility)"
  filter :disability, as: :string
  filter :male_true, as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :female_true, as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :us_citizen_true, label: "US Citizen", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :permanent_resident_true, label: "Permanent Resident", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :other_visa_status_true, label: "International or Other Visa Status", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :hb_1079_true, label: "Undocumented", as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :resident_true, as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :non_resident_true, as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :need_based_true, as: :select, collection: [["Yes", "true"], ["No", "false"]]
  filter :is_national_true, as: :select, collection: [["Yes", "true"], ["No", "false"]]

  
  
  
end
