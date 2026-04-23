ActiveAdmin.register_page "Accountabilities Authorizations" do
  menu false

  controller do
    before_action { check_permission("accountability_manager") }  
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
  sidebar :add_user do
    render partial: "admin/accountabilities/authorizations/sidebar/add_user"
  end

  # GET (this is the AA page “index”)
  content title: "Authorized Users" do
    role = Role.find_or_create_by(name: "accountability_department_coordinator")
    authorizations = role.authorizations.includes(:authorizable)

    departments = {}
    authorizations.each do |authorization|
      dept = authorization.authorizable
      (departments[dept] ||= []) << authorization
    end
    departments = departments.sort_by { |dept, _| dept.name.to_s.downcase }.to_h
    
    render partial: "admin/accountabilities/authorizations/index", locals: { departments: departments }
  end

  # POST /admin/accountability/authorizations (we’ll route alias to here)
  page_action :create, method: :post do
    if params[:uw_netid].blank? || params[:authorizable_key].blank?
      @error = "You must provide department and UW NetID."
      return render "admin/accountabilities/authorizations/create", formats: :js
    end

    role = Role.find_or_create_by(name: "accountability_department_coordinator")
    user = PubcookieUser.authenticate(params[:uw_netid], nil, nil, fail_if_person_not_found: true)
    unless user
      @error = "UW NetID not found."
      return render "admin/accountabilities/authorizations/create", formats: :js
    end
    user_role = user.assign_role(:accountability_department_coordinator)
 
    key = params[:authorizable_key].to_s.strip

    case key
    when /\A(Department|DepartmentExtra)[:_](\d+)\z/
      @department = $1.constantize.find($2)    
    # when /\ANEW_(.+)\z/
    #   @department = DepartmentExtra.find_or_create_by(fixed_name: CGI.unescape($1))
    else
      @error = "Invalid department name format."
      return render "admin/accountabilities/authorizations/create", formats: :js
    end

    @authorization = user_role.authorize_for(@department)
    @error = "Error creating authorization record." unless @authorization

    if @authorization
      template = EmailTemplate.find_by_name("accountability department coordinator authorized notification")

      if template && user.email.present?
        info = {
          authorized_user: user.person,
          department: @department,
          authorized_by: current_user.person # ActiveAdmin current_user
        }

        reporting_url = "https://expd.uw.edu/accountability/"

        EmailContact.log(
          user.person,
          template.create_email_to(info, reporting_url, user.email).deliver_now
        )
      end
    end

    @role = role
    @authorizations = role.authorizations.where(
      authorizable_type: @department.class.to_s,
      authorizable_id: @department.id
    )

    render "admin/accountabilities/authorizations/create", formats: :js
  end

  # DELETE /admin/accountability/authorizations/:id (alias route)
  page_action :destroy, method: :delete do
    @authorization = UserUnitRoleAuthorization.find(params[:id])
    @department = @authorization.authorizable
    @authorization.destroy

    @role = Role.find_or_create_by(name: "accountability_department_coordinator")
    @authorizations = @role.authorizations.where(
      authorizable_type: @department.class.to_s,
      authorizable_id: @department.id
    )

    render "admin/accountabilities/authorizations/destroy", formats: :js
  end

  # GET /admin/accountability/authorizations/auto_complete_for_department (alias route)
  page_action :auto_complete_for_department, method: :get do
    q = params[:q].to_s.strip
    q = q[0, 60] # simple guard

    depts = Department.where("dept_full_nm LIKE ? OR dept_abbr = ?", "%#{q}%", q).limit(10)

    extras = DepartmentExtra.where("fixed_name LIKE ? AND dept_code IS NULL", "%#{q}%").limit(10)

    results = (depts.to_a + extras.to_a).map do |d|
      if d.is_a?(Department)
        {
          id: "Department:#{d.dept_code}",
          text: d.name,
          subtext: "Department ID: #{d.dept_code}"
        }
      else
        {
          id: "DepartmentExtra:#{d.id}",
          text: d.fixed_name,
          subtext: "DepartmentExtra ID: #{d.id}"
        }
      end
    end

    render json: results
  end  
end