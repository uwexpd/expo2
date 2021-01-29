class UsersController < ApplicationController
  skip_before_action :login_required, raise: false
  before_action :check_recaptcha_v2, only: [:create]

  layout 'active_admin_logged_out'
  
  def new
    @user = User.new
  end

  def update
    @user = self.current_user
    @user.person.require_validations = true
    if @user.update_attributes(params[:user]) && @user.person.save
      @user.person.update_attribute(:contact_info_updated_at, Time.now)
      flash[:notice] = "Thanks for updating your profile!"
      redirect_to redirect_to_path || profile_path
    else
      render :action => "profile"
    end
  end

  def profile
    @user = self.current_user    
    if @user == :false
      return redirect_back_or_default(root_url)
    end
    @user.valid? 
  end

  def create
    cookies.delete :auth_token    
    @user = User.new(user_params)
    if User.where("email = ? AND type is NULL", params[:user][:person_attributes][:email].strip).take
      flash[:error] = "This email address is already in use."
      render :action => 'new'
    else      
      @user.email = params[:user][:person_attributes][:email].strip rescue nil
      @user.save!
      self.current_user = @user
      redirect_back_or_default(root_url)
      flash[:notice] = "Thanks for signing up!"
      if email = UserMailer.welcome_signup(@user).deliver_now
        EmailContact.log(@user.person, email)
      end
      successful_login
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  protected
  
  def successful_login
    LoginHistory.login(self.current_user, (request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]), session.id)
    session[:limit_login_to] = nil
  end
  
  private

  def user_params
      params.require(:user).permit(:login, :password, :password_confirmation, person_attributes: [:salutation, :firstname, :lastname, :email])
  end

  def check_recaptcha_v2
    valid = verify_recaptcha secret_key: ENV["RECAPTCHA_V2_CHECKBOX_SECRET_KEY"]

    if not valid
      flash[:error] = "Recaptcha fails. Please let us know you are not a robot."
      redirect_to :action => 'new'
    end
  end  

end
