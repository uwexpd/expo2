ActiveAdmin.register AccountabilityReport do
    batch_action :destroy, false
    config.sort_order = 'year_desc'    
    menu parent: 'Tools'
    config.filters = false
    config.paginate = false
        
    permit_params :year
    
    index title: "Accountability Reports" do
        # Group all reports by year (ensure preloading as needed for efficiency!)
        #grouped = AccountabilityReport.all.includes(:activity_type).group_by(&:year).sort.reverse
        years = AccountabilityReport.years.reverse
      
        years.each do |year|
          # div class: 'panel-content' do
            # Add header/links here as needed
            # link_to "Reporting Status", :action => 'status', id: year
	          # link_to "Department Reporting Interface", accountability_reporting_path(year)
	          # link_to "Compiled Report (Public)", accountability_year_path(year)
            div class: 'content-block', style: 'padding: 0.25rem 1.25rem' do
              div class: 'big-border box' do
                h4 "<strong><i class='mi uw_purple'>calendar_month</i> #{year}</strong>".html_safe
                AccountabilityReport.where(year: year).each do |report|
                  ul class:'link-list' do
                      li do
                        h3 report.title do
                          if report
                            if report.finalized?
                              span status_tag 'finalized', class:'small highlight' 
                            else
                              br
                              span 'Nerver generated', class: 'light'
                            end                            
                            if report.generated_at
                              br
                              span "Generated at #{report.generated_at.to_s(:date_at_time12)}", class: 'caption'
                              # span link_to("Regenerate", regenerate_admin_accountability_report_path(report))
                            else
                              # span link_to("Generate", generate_admin_accountability_report_path(report))
                            end
                          els                            
                            span "Not found", class: 'empty'
                          end
                        end
                      end                
                  end
                end
              end
            end          
        end
    end

    show do
      attributes_table do
        row :year        
      end
    end

    
    sidebar "Actions" do
      ul class: 'link-list' do
        li do
          'link1'
        end
        li do
          'link2'
        end
      end
    end
      
    form do |f|
      semantic_errors *f.object.errors.keys
      f.inputs do  
        f.input :year        
      end
      f.actions
    end
         
    
  end