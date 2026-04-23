class Accountability::Reporting::AuthorizationsController < Accountability::ReportingController
  before_action :add_users_breadcrumbs
  skip_before_action :fetch_service_learning_courses
  
  def index
    @authorizations = @department.accountability_coordinator_authorizations
  end

  def create
    if params[:uw_netid].blank?
      @error = "You must provide a UW NetID."
      return respond_to { |format| format.js }
    end

    user = PubcookieUser.authenticate(params[:uw_netid], nil, nil, fail_if_person_not_found: true)
    unless user
      @error = "UW NetID not found."
      return respond_to { |format| format.js }
    end

    role = user.assign_role(:accountability_department_coordinator)
    @authorization = role.authorize_for(@department)
    unless @authorization
      @error = "Error creating authorization record."
      return respond_to { |format| format.js }
    end

    # Notify the person who was added
    template = EmailTemplate.find_by_name("accountability department coordinator authorized notification")    

    if template && user.email.present?
      info = {
        authorized_user: user.person,
        department: @department,
        authorized_by: @my.person
      }

      reporting_url = "https://#{Rails.configuration.constants['base_url_host']}/accountability/reporting/#{@year}"      

      EmailContact.log(
        user.person,
        template.create_email_to(info, reporting_url, user.email).deliver_now
      )
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @authorization = @department.accountability_coordinator_authorizations.find(params[:id])
    @authorization.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to(accountability_reporting_authorizations_path(@year)) }            
    end
  end

  protected
  
  def add_users_breadcrumbs
    add_breadcrumb "Authorized Users", accountability_reporting_authorizations_path(@year)
  end
end