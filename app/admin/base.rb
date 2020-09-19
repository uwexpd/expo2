ActiveAdmin.register_page "Base" do  
  menu false

  controller do  	  
	  skip_before_action :login_required, :only => :remove_vicarious_login, raise: false

	  def vicarious_login
	    if params[:vicarious_login]
	      identity_type = params[:identity_type].blank? ? nil : params[:identity_type]
	      user = User.find_by_login_and_identity_type(params[:vicarious_login], identity_type)
	    elsif params[:user_id]
	      user = User.find(params[:user_id])
	    else
	      flash[:error] = "You need to provide either a user ID or a username and identity type."
	      return redirect_to root_path
	    end
	    if user
	      return check_permission(:vicarious_login) unless @current_user.has_role?(:vicarious_login)
	      session[:original_user] = @current_user.id
	      session[:vicarious_token] = user.token
	      session[:vicarious_user] = user.id
	      flash[:notice] = "You are now logged in as #{user.fullname}."
	      return redirect_to root_path
	    else
	      flash[:error] = "Could not find the user you requested. Try looking for a different identity type for that user."
	      return redirect_to root_path
	    end
	  end

	  def remove_vicarious_login
	    session[:user] = session[:original_user]
	    session[:original_user] = nil
	    session[:vicarious_token] = nil
	    session[:vicarious_user] = nil
	    redirect_back(fallback_location: root_path)
	  end

	  protected

	  def check_permission(role)
    	unless @current_user.has_role?(role)
      	@role = role.to_s.titleize
        return render :template => "exceptions/permission_denied", :status => :unauthorized
      end

  end


  end

end