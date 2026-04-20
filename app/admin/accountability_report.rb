ActiveAdmin.register AccountabilityReport, as: 'accountabilities' do
  actions :all, except: [:destroy]
  batch_action :destroy, false
  config.sort_order = 'year_desc'    
  menu parent: 'Tools', label: 'Accountability Report'
  config.filters = false
  config.paginate = false

  permit_params :year, :activity_type_id, :quarter_abbrevs, :finalized

  controller do
    before_action { check_permission("accountability_manager") }

    def quarter_abbrevs_for(year)
      ["SUM#{year - 1}", "AUT#{year - 1}", "WIN#{year}", "SPR#{year}"]
    end
    helper_method :quarter_abbrevs_for

    def load_department(department_key)
      key = department_key.to_s
      key.match?(/^\d+/) ? Department.find(key) : key
    end
    helper_method :load_department
  end

  # GET /admin/accountabilities/status?year=2025
  collection_action :reporting_status, method: :get do
    @year = params[:year].to_i
    @quarter_abbrevs = quarter_abbrevs_for(@year)
    @quarters = Quarter.find_by_abbrev(@quarter_abbrevs)

    @departments = {}
    @activity_types = ActivityType.all
    @activities = ActivityCourse.for_quarter(@quarters).to_a + ActivityProject.for_quarter(@quarters).to_a

    @activities.each do |activity|
      department = activity.try(:department) || activity.department_name
      department_object = department.is_a?(String) ? DepartmentExtra.find_or_create_by(fixed_name: department) : department

      @departments[department] ||= begin
        h = {}
        @activity_types.each { |at| h[at.id] = { courses: 0, individuals: 0 } }
        h
      end

      bucket = activity.is_a?(ActivityCourse) ? :courses : :individuals
      @departments[department][activity.activity_type_id][bucket] += 1
      @departments[department][:department_object] = department_object
    end
    @departments = @departments.sort_by { |_, data| data[:department_object]&.name.to_s.downcase }.to_h

    render "status"
  end

  # GET /admin/accountabilities/courses?year=2025&department_key=12
  collection_action :courses, method: :get do
    @year = params[:year].to_i
    @quarter_abbrevs = quarter_abbrevs_for(@year)
    @quarters = Quarter.find_by_abbrev(@quarter_abbrevs)

    @department = load_department(params[:department_key])
    @activity_types = ActivityType.all

    @activities = {}
    @activity_types.each do |a|
      @activities[a.id] ||= {}
      @quarters.each { |q| @activities[a.id][q.id] ||= [] }
    end

    ActivityCourse.for_quarter_and_department(@quarters, @department).find_each do |a|
      @activities[a.activity_type_id][a.quarter_id] << a
    end

    render "courses"
  end

  # GET /admin/accountabilities/individuals?year=2025&department_key=12
  collection_action :individuals, method: :get do
    @year = params[:year].to_i
    @quarter_abbrevs = quarter_abbrevs_for(@year)
    @quarters = Quarter.find_by_abbrev(@quarter_abbrevs)
    
    @department = load_department(params[:department_key])
    @activity_types = ActivityType.all
    @activities = {}

    @activity_types.each do |activity_type|
      @activities[activity_type.id] =
        ActivityProject.for_quarter(@quarters).for_department(@department).of_type(activity_type).includes(:quarters).to_a
    end

    render "individuals"
  end

  # POST /admin/accountabilities/:id/regenerate
  member_action :regenerate, method: :post do
    @report = AccountabilityReport.find(params[:id])    
      
    @report.update_status("Queued...")
    @enqueue_failed = false

    begin
      AccountabilityRegenerateReportJob.perform_later(@report.id)
    rescue => e
      @enqueue_failed = true
      @report.update_status("ERROR: Could not enqueue job (#{e.class}: #{e.message})")
    end

    respond_to do |format|
      format.js 
      format.html { redirect_back fallback_location: resource_path(@report), notice: "Regeneration completed." }
    end
  end

  # GET /admin/accountabilities/:id/regenerate_status
  member_action :regenerate_status, method: :get do
    @report = AccountabilityReport.find(params[:id])    
    @status = AccountabilityReport.status(@report.id).to_s

    @failed = @status.start_with?("ERROR:")
    @complete = @failed || !AccountabilityReport.in_progress?(@report.id)

    respond_to do |format|
      format.js
    end
  end  
  
  index title: "Accountability Reports" do
    div id: "aa-accountability-reports",
    data: { status_url_template: regenerate_status_admin_accountability_path(":id") } do
      years = AccountabilityReport.years.reverse
      years.each do |year|                    
          div class: 'accountabilities content-block' do
            div class: 'big-border box' do
              h4 "<strong><i class='mi uw_purple'>calendar_month</i> #{year}</strong>".html_safe
              span link_to "Reporting Status", reporting_status_admin_accountabilities_path(year: year)
              span "  |  "
              span link_to "Department Reporting Interface", accountability_reporting_path(year)
              span "  |  "
              span link_to "Compiled Report (Public)", accountability_year_path(year)
              AccountabilityReport.where(year: year).each do |report|                  
                ul class:'no-list-style' do
                    li do
                      h3 report.title do                          
                        if report
                          if report.finalized?
                            span status_tag 'finalized', class:'small highlight' 
                          else
                            span class: 'margin_left' do 
                              link_to("Edit", edit_admin_accountability_path(report.id), class: 'button flat small', style: "display: inline; background-color: #4b2e83")
                            end
                          end                            
                          if report.generated_at
                            br
                            div class: 'caption' do
                              span "Generated at #{report.generated_at.to_s(:date_at_time12)} - "
                              span do
                                link_to "Regenerate",
                                        regenerate_admin_accountability_path(report),
                                        method: :post,
                                        remote: true,
                                        id: "regenerate_link_#{report.id}",
                                        style: "display:inline",
                                        data: { confirm: "Are you sure?", report_id: report.id, type: :script }
                              end
                              span id: "regenerate_indicator_#{report.id}", class: 'indicator' do
                                image_tag("loading.gif", class: "loading", style: "display: none;")
                              end
                            end
                            
                          else
                            br
                            span 'Nerver generated - ', class: 'caption'
                            span class: 'caption' do
                                link_to "Generate",
                                        regenerate_admin_accountability_path(report),
                                        method: :post,
                                        remote: true,
                                        id: "regenerate_link_#{report.id}",
                                        style: "display:inline",
                                        data: { confirm: "Are you sure?", report_id: report.id, type: :script }
                            end                            
                          end
                          # (Re)Generate status periodically update
                          in_progress = AccountabilityReport.in_progress?(report.id)

                          div id: "status_indicator_#{report.id}",
                              style: ("display:none" unless in_progress) do                           
                            span "Status", class: "status_tag small"
                            span id: "status_#{report.id}", class: "caption",
                              data: { report_id: report.id, in_progress: in_progress } do
                                text_node(AccountabilityReport.status(report.id).to_s)
                            end                            
                          end

                        else                          
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
  end

  sidebar "Navigation" do
    ul class: 'link-list' do
      li do
        link_to "<i class='mi'>home</i>Accountability Home".html_safe, admin_accountabilities_path
      end
      li do
        link_to "<i class='mi'>group</i>Authorized Users".html_safe, admin_accountability_authorizations_path
      end
    end
  end

  sidebar :department_nav, only: [:courses, :individuals] do
    dept = assigns[:department]
    year = params[:year] || assigns[:year]
    department_key = params[:department_key]

    # This is the visible header you want
    h3(dept.respond_to?(:name) ? dept.name : dept.to_s, class: "dept-sidebar-title")

    ul class: "link-list" do
      li do
        link_to "<i class='mi'>school</i> #{year} Courses".html_safe,
                courses_admin_accountabilities_path(year: year, department_key: department_key)
      end
      li do
        link_to "<i class='mi'>person</i> #{year} Individuals".html_safe,
                individuals_admin_accountabilities_path(year: year, department_key: department_key)
      end
    end
  end

  show do
    attributes_table do
      row :year        
    end
  end    
    
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do  
      f.input :year, input_html: {style: 'width: 197px'}
      f.input :activity_type 
      f.input :quarter_abbrevs
      if f.object.persisted?
        f.input :finalized
      end
    end
    f.actions
  end
       
  
end