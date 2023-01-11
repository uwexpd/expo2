# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  skip_before_action :login_required, :add_to_session_history, raise: false
  
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
  
  def show
    
  end

  def destroy
     reset_session
     flash[:notice] = "You have been logged out."
     if self.current_user.is_a? PubcookieUser
        redirect_to "https://itconnect.uw.edu/security/uw-netids/weblogin/#logout" and return false
     end
     redirect_back_or_default(root_url)
  end
  
  def forgot
    if params[:commit]
      if params[:username]
        user = User.where("login = ? AND type IS NULL", params[:username].strip).take
        flash.now[:alert] = "That username does not exist." and return if user.nil?
        user.create_token
        if email = UserMailer.password_reminder(user).deliver_now
          EmailContact.log(user.person, email)
          flash.now[:notice] = "Instructions have been sent to your email #{user.email} that will tell you how to reset your password."
        end
      elsif params[:email]
        @email_address = params[:email].strip
        @users = User.where("email = ? AND type IS NULL", @email_address)        
        if @users.blank?
          flash.now[:alert] = "Can not find any usernames with this email." and return           
        else
          if email = UserMailer.username_reminder(@email_address, @users).deliver_now
            for user in @users
              EmailContact.log(user.person, email)
            end            
            flash.now[:notice] = "Your username reminder have been sent to your email #{user.email}."
          end
        end        
      end    
    end
  end

  def reset_password
    @user = Token.find_object(params[:user_id], params[:token], false)
    if @user.nil?
      flash[:alert] = "That password reset link is invalid. Please try again."
      redirect_to :action => "forgot" and return
    end
    if request.post? && params[:user]
      @user.allow_invalid_person = true
      if @user.update_attributes(params[:user])
        flash[:notice] = "Your password was successfully reset."
        @user.create_token
        self.current_user = User.authenticate(@user.login, @user.password)
        @user.allow_invalid_person = false
        redirect_to profile_url and return unless @user.valid? && @user.person.valid?
        redirect_to root_url and return
      end
    end
  end

  protected
  
  def password_authentication(username, password)
    self.current_user = User.authenticate(username, password)
    if logged_in?
      successful_login
    else
      flash.now[:alert] = "Authentication failed. The username and password are not matched. Please try again."
      render :action => 'new'
    end
  end
  
  def successful_login
    session[:limit_login_to] = nil
    redirect_back_or_default(root_url)
    flash[:notice] = "Logged in successfully"
    LoginHistory.login(self.current_user, (request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]), session.id)
  end
  
end