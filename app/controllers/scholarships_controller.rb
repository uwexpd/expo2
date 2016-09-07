class ScholarshipsController < ApplicationController

  add_breadcrumb "OSMFA home", "http://expd.uw.edu/scholarships"
  
  def index
    @search = Scholarship.active.ransack(params[:q])
    @scholarships = @search.result(distinct: true).page(params[:page]).order('title')
    
    add_breadcrumb "scholarships search"
  end

  def show
    if params[:page_stub]
      @scholarship = Scholarship.find_by_page_stub params[:page_stub]
      unless @scholarship.is_active?
        flash[:alert] = "The scholarship, #{@scholarship.title}, is inactive. You are not able to see the details."
        redirect_to :action => "index"
      end      
    else
      flash[:alert] = "Cannot find the scholarship."
      redirect_to :action => "index"
    end
    
    add_breadcrumb "scholarships search", scholarships_path
    add_breadcrumb "#{@scholarship.title}"
  end
  
end