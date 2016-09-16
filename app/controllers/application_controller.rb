class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  include AuthenticatedSystem
  
  before_filter :login_required
  
  def authenticate_admin_user!
    unless current_admin_user
      flash[:error] = "Access denied! Please make sure you have admin permission."
      redirect_to :login
    end
  end
  
  def current_admin_user
    return false if !current_user.admin?
    current_user
  end
    
      
      
end
