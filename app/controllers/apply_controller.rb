class ApplyController < ActionController::Base
  skip_before_action :login_required, raise: false
  before_action :student_login_required_if_possible
  before_action :fetch_offering, :except => :list


  def index
    # render index.html.erb
  end




  protected

  def fetch_offering
    @offering = Offering.find params[:offering]
    @reference_quarter = Quarter.find_by_date(@offering.deadline) rescue nil
  end

end