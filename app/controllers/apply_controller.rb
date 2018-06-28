class ApplyController < ActionController::Base
  skip_before_filter :login_required
  before_filter :student_login_required_if_possible
  before_filter :fetch_offering, :except => :list


  def index
    # render index.html.erb
  end




  protected

  def fetch_offering
    @offering = Offering.find params[:offering]
    @reference_quarter = Quarter.find_by_date(@offering.deadline) rescue nil
  end

end