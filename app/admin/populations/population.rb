ActiveAdmin.register Population, as: 'query' do
  batch_action :destroy, false
  menu parent: 'Modules', label: "<i class='mi padding_right'>find_in_page</i> Queries".html_safe, priority: 45
  config.sort_order = 'updated_at_desc'
  config.per_page = [50, 100, 200, 400]

  permit_params :title, :description, :access_level, :populatable_type, :populatable_id, :starting_set,  :condition_operator, :result_variant, :custom_result_variant, :custom_query,
      conditions_attributes: [
                  :id, 
                  :eval_method, 
                  :value, 
                  :skip_validations, 
                  :_destroy
                ]

  scope 'My Queries', default: true do |query|
    query.creator(current_user)
  end
  scope 'My Program(s) Queries' do |query|
    query.unit(current_user)
  end
  scope 'Everyone', :everyone
  scope :all

  controller do
    before_action :fetch_populations, only: [ :objects, :results, :refresh_dropdowns, :output]

    def edit
      populate_vars_by_access_level
    end

    def refresh_dropdowns      
      @population.update(populatable_type: params[:populatable_type]) if params[:populatable_type]
      @population.update(starting_set: params[:starting_set]) if params[:starting_set]
      
      populate_vars_by_access_level
      
      respond_to do |format|
        format.js
      end
    end

     def update
      @population = Population.find(params[:id])
      @population.attributes = permitted_params[:population]
      @population.system = false
      @population.custom_query = nil if params[:use_custom_query] != "true" || !current_user.has_role?(:custom_query_writer)      

      if @population.save        
        begin
          @population.generate_objects!          
        rescue
          if @population.custom_query?
            @population.errors.add(:base, "Your custom query is not valid. Please try again or select a starting set instead.")
          else
            @population.errors.add(:base, "There was an error while generating your query.")
          end
          flash.now[:alert] = @population.errors.full_messages.join(', ')
          return render :edit
        end

        # expire_action action: 'show', format: :xls
        # expire_action controller: 'stats', action: 'population'

        flash[:notice] = "Successfully updated query."
        redirect_to resource_path(@population)
      else
        render :edit        
      end
    end

    protected

    def fetch_populations
      @population = Population.find(params[:id])
      @objects = @population.objects
    end

    def populate_vars_by_access_level
      @user_populations = Population.creator(@current_user).user_created # + PopulationGroup.creator(@current_user)
      @unit_populations = Population.unit(@current_user).user_created # + PopulationGroup.unit(@current_user)
      @everyone_populations = Population.everyone.user_created # + PopulationGroup.everyone
    end

    # private
    # def population_params
    #   params.require(:population).permit(:title, :description, :access_level, :populatable_type, :populatable_id, :starting_set)
    # end
  end


  member_action :objects, method: :get do
    respond_to do |format|
      format.html
      format.js {
        if @population.output_fields.blank?
          render :partial => "objects"
        else
          redirect_to results_admin_query_path(@population)
          #redirect_to action: :show, format: :xlsx
        end
      }
    end
  end

  member_action :results, method: :get do
    respond_to do |format|
      format.html do
        render partial: 'results', locals: { population: @population }
      end 
      format.js
    end
  end

  member_action :output, method: :get do
    respond_to do |format|
      format.html
    end
  end

  member_action :save_output_fields, method: :put do
  @population = Population.find(params[:id])
  if @population.update(output_fields: params[:output_fields])
    respond_to do |format|
      format.js { render js: "$('#save_output_fields_status').html('<span class=\"uw_green\"><i class=\"mi\">check_circle</i> Saved</span>');" }
    end
  else
    respond_to do |format|
      format.js { render js: "$('#save_output_fields_status').html('<span class=\"mi red_color\">error</span> Save Failed');" }
    end
  end
end

  member_action :copy, method: :post do
    original_query = Population.find(params[:id])

    if copy_query = original_query.deep_dup!      
      redirect_to edit_admin_query_path(copy_query), notice: "Successfully copied #{original_query.title}. You can customize the details below."
    else
      redirect_to admin_query_path(original_event), alert: "An error occurred while cloning the query."
    end
  end

  member_action :regenerate, method: :post do
    @population = Population.find(params[:id])
    begin
        @population.generate_objects!
        flash[:notice] = "Successfully regenerated query results."  
    rescue
        if @population.custom_query?
          flash[:alert] = "Your custom query is not valid. Please update it or select a starting set instead."
        else
          flash[:alert] = "There was an error while generating your query."            
        end
    end

    # Rails 5+ doesn't have expire_action by default; if you use caching,
    # you may need to expire caches differently, or skip if not used.
    # expire_action action: 'show', format: :xls
    # expire_action controller: 'stats', action: 'population'

    

    respond_to do |format|
      format.html { redirect_to resource_path(@population) }
      format.js   { render layout: false }
    end
  end

  member_action :download, method: :get do
    @population = Population.find(params[:id])
    if @population.output_fields.blank?
      redirect_to resource_path(@population), alert: "Please select fields before downloading."
      return
    end
    @objects = @population.objects
    respond_to do |format|       
        format.xlsx { render xlsx: 'download', filename: "Report_#{@population.title}_#{@population.id}.xlsx" }
      end
  end

  action_item :copy, only: :show do
     link_to 'Copy Query', copy_admin_query_path(resource), method: :post, data: { confirm: 'Are you sure you want to copy this query?' }
  end

  index do
    column ('Title'){|population| link_to population.title, admin_query_path(population) }
    column ('Results') {|population| population.read_attribute(:objects_count) }
    column ('Generated') do |population|  
       if population.objects_generated_at
          span "#{time_ago_in_words population.objects_generated_at} ago", class: "smaller #{ 'red_color' if Time.now - population.objects_generated_at > 1.month}"
       else
          span "Never",class: 'red_color'
       end
    end
    column ('Creator') {|population| population.creator.firstname_first rescue nil }
    actions default: true do |population|
      link_to 'Copy Query', copy_admin_query_path(population), method: :post, data: { confirm: 'Are you sure you want to copy this query?' }
    end
  end

  show do
    panel "#{resource.title}".html_safe, class: ' panel_contents' do
      div class: 'content-block caption' do
        status_tag 'auto-generated', class: 'small orange right' if resource.system?
        status_tag 'manual', class: 'small right' if resource.is_a?(ManualPopulation)        
        span object_timestamp_details(resource)        
      end
       
    end

    attributes_table title: "<i class='mi uw_purple'>info</i> Details".html_safe do
      unless resource.description.blank?
        row ('Description') {|q| q.description.html_safe }
      end
      if resource.custom_query?
        row ('Query') {|q| q.custom_query }
      elsif !resource.is_a?(ManualPopulation)
        row ('Based on') do |q|
          span q.populatable_type
          id_str = q.populatable.identifier_string rescue q.populatable.title rescue q.populatable.name rescue nil
          span q.populatable_type == "Population" ? link_to(id_str, population_path(q.populatable)) : id_str
          span "(#{q.starting_set})" if q.starting_set
        end

        unless resource.conditions.empty?
          row ('Conditions') do |q|
            para "Matching #{q.condition_operator} of the following conditions:"
            ul class: 'left-indent' do
              q.conditions.each do |condition|
                li do
                  span condition.attribute_name, class: 'outline tag'
                  span condition.eval_method
                  span condition.value, class: 'outline tag'
                end
              end
            end
          end
        end

        unless resource.result_variant.blank?
          row ('Result set') {|q| q.result_variant }        
        end

      end
        
      unless resource.is_a?(ManualPopulation)
        row ('Generated') {|q| span "#{time_ago_in_words(q.objects_generated_at)} ago", class: "#{'red_color' if Time.now - q.objects_generated_at > 1.month}" if q.objects_generated_at }
      end

      row ('Results') do |q|
        span (pluralize q.objects.size, "record") + " - "
        span class: 'smaller' do
          link_to "Regenerate".html_safe, regenerate_admin_query_path(resource), method: :post, data: { confirm: 'Are you sure?' }
        end
      end

      row ('Output') do |q|
        if q.output_fields.blank?
          span "No output fields have been defined. ", class: 'light'
          span link_to "<i class='mi'>ballot</i> Create one".html_safe, output_admin_query_path(resource), class: 'button smaller'
        else
          span link_to "<i class='mi'>ballot</i> Edit output fields".html_safe, output_admin_query_path(resource), class: 'button smaller right'

          ul id: "selected_population_field_codes", class: "population_field_codes readonly" do
            q.output_fields.each do |code|
              if code.match(/^CUSTOM_OUTPUT_FIELD\((.+)\):(.+)/)
                custom_output_field = true
                association_name = code.match(/^CUSTOM_OUTPUT_FIELD\((.+)\):(.+)/)[1]
                code = code.match(/^CUSTOM_OUTPUT_FIELD\((.+)\):(.+)/)[2]
                code_text = "#{code}"
                custom_tag = "<span class=\"custom outline tag\" style=\"margin-left:0\">Custom</span>"
              else
                custom_output_field = false
                association_name = code.split(".").size > 1 ? code.split(".").first.titleize : q.objects.first.class.to_s.titleize
                # code_text = code.split(".").last
                code_text = code.split(".").size > 1 ? code.split(".")[1..(code.split(".").size-1)].join(".") : code
                custom_tag = ""
              end 
              association_text_span = content_tag(:span, association_name, :class => 'association')
              
              li class: "#{'custom_output_field' if custom_output_field}" do
                 span raw(custom_tag + association_text_span + "<i class='mi'>arrow_right</i>" + code_text), class: "placeholder_text_link"
              end
            end
          end
        end
      end

    end # end of attributes_table
    
    panel "<i class='mi uw_purple'>table_view</i> Results".html_safe, class: 'panel_contents' do
      div class: 'content-block' do
        div class: 'big-border box gray', style: 'display: grid' do
          h4 do
            span "<i class='mi'>view_list</i> #{ pluralize resource.objects.size, 'record' }".html_safe
            span link_to "<i class='mi'>fullscreen</i> Open in the new window".html_safe, objects_admin_query_path(resource),class: 'right'
          end
          
          div id: 'objects_placeholder', style: 'overflow:auto; display: none'          

          div link_to "<i class='mi'>visibility</i> Show Details".html_safe, "#", id: 'show-details-button', class: 'button small flat', data: { id: resource.id, path: results_admin_query_path(resource) }

          div id: 'objects_indicator', style: 'display:none' do
            span image_tag('loading.gif', class: 'loading')
            span " Loading results...", class: 'light'
          end
        end
        
      end
      
    end


  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :title
      f.input :description, input_html: { :class => "tinymce", :rows => 5 }
      f.input :access_level, label: 'Share with', as: :select, collection: [["Just Me", "creator"], ["My program(s) staff", "unit"], ["Everyone", "everyone"]], include_blank: false

      unless f.object.new_record? || f.object.is_a?(ManualPopulation)
        div class: 'panel_contents' do
          div :class => 'content-block' do
            render "starting_set", { :population => f.object }
          end
        end
        div class: 'panel_contents' do
          div :class => 'content-block' do
            render "conditions", { :population => f.object }
          end
        end
        div class: 'panel_contents' do
          div :class => 'content-block' do
            render "result_variant", { :population => f.object }
          end
        end
      end
    end
    f.actions do
      f.action :submit, label: f.object.new_record? ? "Create Query" : "Update Query"
      f.cancel_link
    end
  end

  sidebar "Actions", only: [:show, :edit, :output] do
    ul class: 'link-list' do
      li do
        span link_to "<i class='mi'>content_copy</i> Copy this query".html_safe, copy_admin_query_path(resource), method: :post, data: { confirm: 'Are you sure?' }
      end
      li do
        span link_to "<i class='mi'>ballot</i> Edit Output Fields".html_safe, output_admin_query_path(resource)
      end
      li do
        span link_to "<i class='mi'>table_view</i> Results".html_safe, objects_admin_query_path(resource)
      end
      li do
        span link_to "<i class='mi'>sim_card_download</i> Spreadsheet Download".html_safe, download_admin_query_path(resource, :format => :xlsx)
      end
      li do
        span link_to "<i class='mi'>refresh</i> Regenerate".html_safe, regenerate_admin_query_path(resource), method: :post, data: { confirm: 'Are you sure?' }
      end
    end
  end

  filter :title

end