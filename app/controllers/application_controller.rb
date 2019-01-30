class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true
  
  include AuthenticatedSystem

  rescue_from ::ExpoException, :with => :expo_exception
  rescue_from ActionController::RedirectBackError, :with => :redirect_exception
  
  before_filter :login_required, :except => :remove_vicarious_login
  before_filter :save_user_in_current_thread
  before_filter :save_return_to
  before_filter :add_to_session_history
  before_filter :verify_uwsdb_connection
  # before_filter :check_if_contact_info_blank
  
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

  def remove_vicarious_login
      session[:user] = session[:original_user]
      session[:original_user] = nil
      session[:vicarious_token] = nil
      session[:vicarious_user] = nil      
      redirect_to :redirect_root
  end

  # Add return_to to session if it's been requested
  def save_return_to
    session[:return_to] = params[:return_to] unless params[:return_to].blank?
  end

  def redirect_to_path
    new_path = session[:return_to]
    session[:return_to] = nil
    new_path || root_url
  end

  # Forces a reconnect to the UWSDB by calling #reconnect! on the StudentInfo.connection object. If we aren't able
  # to connect, for any reason, then we render the uwsdb_error exception page along with a 503 status.
  def verify_uwsdb_connection
    ret = ""
    cmd = "StudentInfo.connection.reconnect!"
    time = Benchmark::realtime { ret = eval(cmd) }
    logger.info { "  \e[4;33;1mVerify UWSDB Connection (#{time.to_s[0..8]})\e[0m   #{cmd}" }
  rescue => e
    render :template => "exceptions/uwsdb_error", :layout => false, :status => 503
    logger.info { "  \e[4;33;1mVerify UWSDB Connection (#{time.to_s[0..8]})\e[0m   #{e}" }
  end

  def call_rake(task, log_file, options = {})
      options[:rails_env] ||= RAILS_ENV
      log_file ||= "rake"
      args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
      system "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{RAILS_ROOT}/log/#{log_file}.log"
      exit! 127
  end

  private

  def save_user_in_current_thread
    Thread.current['user'] = current_user
  end

  def expo_exception(exception)
    @exception = exception
    render :template => "exceptions/expo_exception", :status => 200
  end

  def redirect_exception(exception)
    flash[:error] = "EXPO tried to redirect you back to the previous page, but there's no previous 
                     page to redirect you back to. You're going to have to find your own way from here."
    redirect_to root_url and return
  end

  def add_to_session_history
    SessionHistory.create(:session_id => request.session.id,
                          :request_uri => request.original_fullpath,
                          :request_method => request.method.to_s)
  end

  # def check_if_contact_info_is_current
  #   if current_user && !current_user.person.contact_info_updated_since(12.months.ago)
  #     flash[:notice] = "You haven't updated your contact information for awhile. Please confirm your contact information below."
  #     return redirect_to profile_path(:return_to => request.url)
  #   end
  # end

  # # This is only for UW Standard users since EXPO updates student info via Student Web Service directly
  # # No need for external expo users since they need to fill contact information when creating accounts.
  # def check_if_contact_info_blank
  #   if current_user && current_user.user_type == "UW Standard user" && current_user.person.contact_info_updated_at.blank?
  #     flash[:notice] = "Please update your contact information."
  #     return redirect_to profile_path(:return_to => request.url)
  #   end
  # end

      
end
