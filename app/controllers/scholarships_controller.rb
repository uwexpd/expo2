class ScholarshipsController < ApplicationController

  add_breadcrumb 'OSMFA Home', Unit.find_by_abbreviation('omsfa').home_url
  
  skip_before_action :login_required, :add_to_session_history
  
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
    @search = Scholarship.upcoming.ransack(params[:q]) if params[:scope] == 'upcoming'
    @scholarships = @search.result.includes(:scholarship_deadlines).page(params[:page]).uniq.order('scholarships.title')
    
    add_breadcrumb "Scholarships Search"
  end

  def show
    add_breadcrumb "Scholarships Search", scholarships_path

    if params[:page_stub] 
      @scholarship = Scholarship.find_by_page_stub params[:page_stub]
      if @scholarship
        unless @scholarship.is_active?
          flash[:alert] = "The scholarship, #{@scholarship.title}, is inactive. You are not able to see the details."
          redirect_to :action => "index"
        end
        add_breadcrumb "#{@scholarship.title}"
      else
        flash[:alert] = "Cannot find the scholarship."
        redirect_to :action => "index"
      end            
    end        
  end
  
end