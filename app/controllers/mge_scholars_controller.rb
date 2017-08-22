class MgeScholarsController < ApplicationController

  add_breadcrumb 'MGE home', Unit.find_by_abbreviation('mge').home_url
  
  skip_before_filter :login_required
  before_filter :fetch_mge_awardees, :fetch_majors, :fetch_mentor_departments
  
  
  def index
    
    if params[:student_major] && params[:mentor_department].blank?
      params[:q][:id_in] = @majors.values_at(params[:student_major]).flatten.compact.map(&:to_s)
    end    
    if params[:mentor_department] && params[:student_major].blank?
      params[:q][:id_in] = @mentor_departments.values_at(params[:mentor_department]).flatten.compact.map(&:to_s)
    end    
    if !params[:student_major].blank? && !params[:mentor_department].blank?
      major_result = @majors.values_at(params[:student_major]).flatten.compact.map(&:to_s)
      dept_result = @mentor_departments.values_at(params[:mentor_department]).flatten.compact.map(&:to_s)
      params[:q][:id_in] = major_result & dept_result
    end
    
    @search = @mge_awardees.ransack(params[:q])
    
    if params[:q]
      @scholars = @search.result.joins(:person).page(params[:page]).merge(Person.order(firstname: :asc))
    else
      @scholars = @search.result.page(params[:page]).order('ID DESC')
    end        
    
    add_breadcrumb "scholars search"
  end

  def fetch_mge_awardees
    @mge_awardees = ApplicationForOffering.mge_awardees
  end 

  def fetch_majors
    @majors = ApplicationForOffering.awardees_majors_mapping
  end
  
  def fetch_mentor_departments
    @mentor_departments = ApplicationForOffering.mentor_departments_mapping
  end
  
end