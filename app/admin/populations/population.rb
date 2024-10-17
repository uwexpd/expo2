ActiveAdmin.register Population, as: 'queries' do
  batch_action :destroy, false
  actions :all, except: [:new, :edit]
  menu parent: 'Modules', label: "<i class='mi padding_right'>find_in_page</i> Queries".html_safe, priority: 45
  config.sort_order = ['title']
  config.per_page = [50, 100, 200, 400]

  scope 'My Queries', default: true do |queries|
    queries.creator(current_user)
  end
  scope 'My Program(s) Queries' do |queries|
    queries.unit(current_user)
  end
  scope 'Everyone', :everyone
  scope :all

  controller do
    before_action :fetch_populations, only: [ :objects, :results]

    protected

    def fetch_populations
      @population = Population.find(params[:id])
      @objects = @population.objects
    end
  end

  member_action :objects, method: :get do
    respond_to do |format|
      format.html
      format.js {
        if @population.output_fields.blank?
          render :partial => "objects"
        else
          redirect_to results_admin_query_path(@population)
        end
      }
    end
  end

  member_action :results, method: :get do        
    # render partial: 'results', locals: { population: @population }    
    respond_to do |format|
      format.html do
        render partial: 'results', locals: { population: @population }
      end 
      format.js 
      # {
        # html_content = render_partial('results', population: @population )
        # console.log(html_content)
        # html_content = render_to_string(partial: 'results', locals: { population: @population })
        # Respond with JavaScript that updates the DOM

        # render js: "$('#data_table').html('#{j html_content}');"
      #   render js: "$('#data_table').html('<%= j render 'results', {population: @population} %>');"
      # }
    end
    
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
    actions
  end

  show do
    panel "#{queries.title}".html_safe, class: ' panel_contents' do
      div class: 'content-block caption' do
        status_tag 'auto-generated', class: 'small orange right' if queries.system?
        status_tag 'manual', class: 'small right' if queries.is_a?(ManualPopulation)        
        span object_timestamp_details(queries)
      end
       
    end

    attributes_table title: "<i class='mi'>info</i> Details".html_safe do
      unless queries.description.blank?
        row ('Description') {|q| q.description.html_safe }
      end
      if queries.custom_query?
        row ('Query') {|q| q.custom_query }
      elsif !queries.is_a?(ManualPopulation)
        row ('Based on') do |q|
          span q.populatable_type
          id_str = q.populatable.identifier_string rescue q.populatable.title rescue q.populatable.name rescue nil
          span q.populatable_type == "Population" ? link_to(id_str, population_path(q.populatable)) : id_str
          span "(#{q.starting_set})"
        end

        unless queries.conditions.empty?
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

        unless queries.result_variant.blank?
          row ('Result set') {|q| q.result_variant }        
        end

      end
        
      unless queries.is_a?(ManualPopulation)
        row ('Generated') {|q| span "#{time_ago_in_words(q.objects_generated_at)} ago", class: "#{'red_color' if Time.now - q.objects_generated_at > 1.month}" }      
      end

      row ('Result') {|q| pluralize q.objects.size, "record" }
      
      row ('Outputs') do |q|
        if q.output_fields.blank?
          span "No output fields have been defined. ", class: 'light'
          # span link_to("Create one.", output_population_path(q))
        end
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

    end # end of attributes_table
    
    panel "<i class='mi'>table_view</i> Results".html_safe, class: 'panel_contents' do
      div class: 'content-block' do
        div class: 'big-border box gray', style: 'display: grid' do
          h4 do
            span "<i class='mi'>view_list</i> #{ pluralize queries.objects.size, 'record' }".html_safe
            span link_to "<i class='mi'>fullscreen</i> Open in the new window".html_safe, objects_admin_query_path(queries),class: 'right'
          end
          
          div id: 'objects_placeholder', style: 'overflow:auto; display: none'          

          div link_to "<i class='mi'>visibility</i> Show Details".html_safe, "#", id: 'show-details-button', class: 'button small flat', data: { id: queries.id, path: results_admin_query_path(queries) }

          div id: 'objects_indicator', style: 'display:none' do
            span image_tag('loading.gif', class: 'loading')
            span " Loading results...", class: 'light'
          end
        end
        
      end
      
    end


  end

  sidebar 'Actions', only: :show do

  end


  filter :title

end