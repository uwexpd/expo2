ActiveAdmin.register HelpText do
  batch_action :destroy, false
  config.sort_order = 'object_type_asc'
  menu parent: 'Tools'
  config.per_page = [30, 50, 100, 200]

  # One resource manages both HelpText and ModelHelpText (STI)
  permit_params :type, :key, :object_type, :attribute_name,
                :title, :caption, :example, :tech_note, :plain_text

  scope :all, default: true
  scope("Model Help Text") { |s| s.where(type: "ModelHelpText") }
  scope("Other Text Blocks") { |s| s.where(type: nil) }  

  filter :object_type
  filter :type, as: :select, collection: [["HelpText", nil], ["ModelHelpText", "ModelHelpText"]]
  filter :key  
  filter :attribute_name  
  

  index do    
    column (:object_type) {|r| link_to r.object_type, admin_help_text_path(r)}
    column(:type) { |r| r.type.presence || "HelpText" }
    column :key
    column "Attribute", :attribute_name    
    actions
  end

  show do
    attributes_table do
      row(:type) { |r| r.type.presence || "HelpText" }
      row :key
      row :object_type
      row :attribute_name
      row :title
      row (:caption) { |r| raw r.caption }
      row (:example) { |r| raw r.example }
    end
  end

  form do |f|
    f.semantic_errors

    is_model = f.object.is_a?(ModelHelpText) || f.object.type == "ModelHelpText"
    models = Population.model_names.sort

    f.inputs do
      if f.object.new_record?
        f.input :type,
                as: :select,
                include_blank: "OtherHelpText (key-based)",
                collection: [["ModelHelpText (model/attribute)", "ModelHelpText"]],
                selected: "ModelHelpText",
                input_html: { id: "help_text_type_select" }
      else
        f.input :type, as: :hidden
      end

      # Render BOTH groups; JS (on new) can toggle them. On edit, we hide one via style.
      div id: "help_text_model_fields", style: (is_model ? nil : "display:none;") do
        # inside help_text_model_fields
        if f.object.new_record?
          f.input :object_type,
                  as: :select,
                  collection: models,
                  include_blank: "Select a model",
                  input_html: { id: "help_text_object_type", class: 'select2 half-width-select'}

          f.input :attribute_name,
                  as: :select,
                  collection: [],
                  include_blank: "Select an attribute",
                  input_html: { id: "help_text_attribute_name" }
        else
          # Read-only display on edit
          f.input :object_type, input_html: { readonly: true, class: 'aa-readonly-disabled' }
          f.input :attribute_name, input_html: { readonly: true, class: 'aa-readonly-disabled' }
        end
        f.input :title, input_html: { style: "width: 50%;" }        
        f.input :example, as: :text, input_html: { class: "tinymce" }
      end

      div id: "help_text_key_fields", style: (is_model ? "display:none;" : nil) do
        li class: "string input" do
          label "Object Type"          
          div do
            resource.object_type  
          end
        end
        f.input :key        
      end
      
      f.input :caption, label: "Caption/Text", as: :text, input_html: { class: "tinymce" }

    end

    f.actions
  end

  controller do
    # Make sure blank type becomes nil (plain HelpText), not ""
    def create
      normalize_type_param
      super
    end

    def update
      normalize_type_param
      super
    end

    private

    def normalize_type_param
      return unless params[:help_text].is_a?(ActionController::Parameters)
      params[:help_text][:type] = nil if params[:help_text][:type].blank?
    end
  end

  collection_action :model_attributes, method: :get do
    klass = params[:model].to_s.safe_constantize

    attrs =
      if klass && klass < ApplicationRecord
        klass.column_names.sort
      else
        []
      end

    render json: attrs
  end

end