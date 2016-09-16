class ScholarshipsController < ApplicationController

  add_breadcrumb "OSMFA home", "http://expd.uw.edu/scholarships"
  
  skip_before_filter :login_required
  
  def index
    if params[:q]
      selected_categories = params[:q][:scholarship_categories_category_id_in].reject(&:blank?) unless params[:q][:scholarship_categories_category_id_in].nil?
      unless selected_categories.blank?
        categories_with_sub = selected_categories
        selected_categories.each do |category_id|
          categories_with_sub += Category.find(category_id).sub_categories.collect{|s| s.id.to_s }
        end
        params[:q][:scholarship_categories_category_id_in] = categories_with_sub
      end
    end
    @search = Scholarship.active.ransack(params[:q])
    @scholarships = @search.result.includes(:scholarship_deadlines).page(params[:page]).uniq.order('title')
    
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