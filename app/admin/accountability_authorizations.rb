ActiveAdmin.register_page "Accountability Authorizations" do
  menu false

  controller do
    before_action { check_permission("accountability_manager") }  
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
    
    render partial: "admin/accountability/authorizations/index", locals: { departments: departments }
  end

  # POST /admin/accountability/authorizations (we’ll route alias to here)
  page_action :create, method: :post do
    if params[:uw_netid].blank? || params[:authorizable_key].blank?
      @error = "You must provide department and UW NetID."
      return render "admin/accountability/authorizations/create", formats: :js
    end

    role = Role.find_or_create_by(name: "accountability_department_coordinator")
    user = PubcookieUser.authenticate(params[:uw_netid])
    user_role = user.assign_role(:accountability_department_coordinator)

    key = params[:authorizable_key].to_s
    if (m = key.match(/^NEW_(.+)/))
      @department = DepartmentExtra.find_or_create_by(fixed_name: CGI.unescape(m[1]))
    elsif (m = key.match(/^(Department|DepartmentExtra)_(\d+)/))
      @department = m[1].constantize.find(m[2])
    else
      @error = "Invalid department name format."
      return render "admin/accountability/authorizations/create", formats: :js
    end

    @authorization = user_role.authorize_for(@department)
    @error = "Error creating authorization record." unless @authorization

    @role = role
    @authorizations = role.authorizations.where(
      authorizable_type: @department.class.to_s,
      authorizable_id: @department.id
    )

    render "admin/accountability/authorizations/create", formats: :js
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

    render "admin/accountability/authorizations/destroy", formats: :js
  end

  # GET /admin/accountability/authorizations/auto_complete_for_department (alias route)
  page_action :auto_complete_for_department, method: :get do
    @q = params[:department_search].to_s
    depts  = Department.where("dept_full_nm LIKE ? OR dept_abbr = ?", "%#{@q}%", @q).limit(10)
    extras = DepartmentExtra.where("fixed_name LIKE ? AND dept_code IS NULL", "%#{@q}%").limit(10)
    @departments = depts.to_a + extras.to_a

    render partial: "admin/accountability/authorizations/auto_complete_for_department"
  end
end