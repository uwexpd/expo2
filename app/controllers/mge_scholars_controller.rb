class MgeScholarsController < ApplicationController

  add_breadcrumb 'MGE Home', Unit.find_by_abbreviation('mge').home_url
  
  skip_before_action :login_required, :add_to_session_history, raise: false
  before_action :fetch_mge_awardees, :fetch_majors, :fetch_mentor_departments
  
  
  def index
    mentor_search = false
    unless params[:mentor_name].blank?
      mentor_search = true
      mentor_result = find_by_mentor_name(params[:mentor_name]).collect{|a|a.id.to_s}
      params[:q][:id_in] = mentor_result
    end

    if !params[:student_major].blank? && params[:mentor_department].blank?
      if mentor_result.blank?        
        params[:q][:id_in] = @majors.values_at(params[:student_major]).flatten.compact.map(&:to_s)
      else
        params[:q][:id_in] = @majors.values_at(params[:student_major]).flatten.compact.map(&:to_s) & mentor_result
      end
    end    
    if !params[:mentor_department].blank? && params[:student_major].blank?
      if mentor_result.blank? 
        params[:q][:id_in] = @mentor_departments.values_at(params[:mentor_department]).flatten.compact.map(&:to_s)
      else
        params[:q][:id_in] = @mentor_departments.values_at(params[:mentor_department]).flatten.compact.map(&:to_s) & mentor_result
      end
    end    
    if !params[:student_major].blank? && !params[:mentor_department].blank?
      major_result = @majors.values_at(params[:student_major]).flatten.compact.map(&:to_s)
      dept_result = @mentor_departments.values_at(params[:mentor_department]).flatten.compact.map(&:to_s)
      if mentor_result.blank? 
        params[:q][:id_in] = major_result & dept_result
      else
        params[:q][:id_in] = major_result & dept_result & mentor_result
      end
    end
    
    if mentor_search && params[:q][:id_in].blank?
      params[:q][:id_in] = "0" # force rendering to no result page
    end
      
    @search = @mge_awardees.ransack(params[:q])
    
    if params[:q]
      @scholars = @search.result.includes(:person, {offering: :quarter_offered}).page(params[:page]).order('people.firstname, people.lastname ASC')
    else
      @scholars = @search.result.includes(:person, {offering: :quarter_offered}).page(params[:page]).order('application_for_offerings.ID DESC')
    end        
    
    add_breadcrumb "Scholars Search"
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
  
  private 
  
  def find_by_mentor_name(keyword)
    @mge_awardees.includes({mentors: :person}).where("application_mentors.primary = 1 and CONCAT_WS(' ', `people`.`firstname`, `people`.`lastname`) LIKE ?", "%#{keyword}%").order("people.firstname, people.lastname")
  end
  
end