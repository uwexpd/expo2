# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  skip_before_filter :login_required
  
  layout 'active_admin_logged_out'
  
  def create
    auth = request.env["omniauth.auth"]
    if !auth.nil? && auth["provider"] == "shibboleth"        
        redirect_back_or_default(root_url)
        return
    else
       password_authentication(params[:username], params[:password])
    end   
  end
  
  def destroy
     reset_session
     flash[:notice] = "You have been logged out."
      # if self.current_user.is_a? PubcookieUser
      #         redirect_to "http://www.washington.edu/computing/weblogin/logout.html" and return false
      #       end
     render :action => 'new'
  end
    
  protected
  
  def password_authentication(username, password)
    self.current_user = User.authenticate(username, password)
    if logged_in?
      successful_login
    else
      flash.now[:error] = "Authentication failed."
      render :action => 'new'
    end
  end
  
  def successful_login
    session[:limit_login_to] = nil
    redirect_back_or_default(root_url)
    flash[:notice] = "Logged in successfully"
    LoginHistory.login(self.current_user, (request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]), request.session_options[:id])    
  end
  
end