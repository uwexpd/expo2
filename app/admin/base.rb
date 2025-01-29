ActiveAdmin.register_page "Base" do  
  menu false

  controller do
	  skip_before_action :login_required, only: :remove_vicarious_login, raise: false
	  before_action :check_ferpa_reminder_date, :except => [ 'ferpa_reminder', 'ferpa_statement', 'remove_vicarious_login', 'vicarious_login' ]

	  def ferpa_reminder
	    if request.post? && params[:commit]
	      @current_user.update(ferpa_reminder_date: Time.now)
	      return redirect_to admin_path
	    end
	  end

	  def ferpa_statement
	    # session[:breadcrumbs].add "Statement of Responsibilities Regarding FERPA Requirements"
	  end

	  def vicarious_login
	    if !params['vicarious_login'].blank?
	      identity_type = params[:identity_type].blank? ? nil : params[:identity_type]
	      user = User.find_by_login_and_identity_type(params[:vicarious_login], identity_type)
	    elsif !params['user_id'].blank?
	      user = User.find(params[:user_id])
	    else
	      flash[:alert] = "You need to provide either a user ID or a username and identity type."
	      return redirect_to admin_path
	    end
	    if user
	      return check_permission(:vicarious_login) unless @current_user.has_role?(:vicarious_login)
	      session[:original_user] = @current_user.id
	      session[:vicarious_token] = user.token
	      session[:vicarious_user] = user.id
	      flash[:notice] = "You are now logged in as #{user.fullname}."
	      return redirect_to root_path
	    else
	      flash[:alert] = "Could not find the user you requested. Try looking for a different identity type for that user."
	      return redirect_to admin_path
	    end
	  end

  end

  sidebar "Helpful Links", only: [:ferpa_reminder, :ferpa_statement] do
    render "admin/base/sidebar/ferpa_links"
  end

end