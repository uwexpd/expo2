class MgeScholarsController < ApplicationController

  add_breadcrumb 'MGE Home', Unit.find_by_abbreviation('mge').home_url
  
  skip_before_action :login_required, :add_to_session_history, raise: false
  before_action :fetch_mge_awardees, :fetch_majors, :fetch_mentor_departments, :fetch_campus
  
  def index
    # Collect each active filter's matching IDs as separate arrays
    filters = []
    filters << find_by_mentor_name(params[:mentor_name]).pluck(:id).map(&:to_s) unless params[:mentor_name].blank?
    filters << @majors.values_at(params[:student_major]).flatten.compact.map(&:to_s) unless params[:student_major].blank?
    filters << @mentor_departments.values_at(params[:mentor_department]).flatten.compact.map(&:to_s) unless params[:mentor_department].blank?
    filters << @campus.values_at(params[:student_campus]).flatten.compact.map(&:to_s) unless params[:student_campus].blank?
    
    # Intersect all active filters and scope the base relation directly
    # (avoids mutating params[:q][:id_in] which breaks will_paginate's COUNT introspection)
    if filters.any?
      combined = filters.reduce(:&)
      @mge_awardees = combined.any? ? @mge_awardees.where(id: combined) : @mge_awardees.none
    end

    @search = @mge_awardees.ransack(params[:q])

    order_clause = params[:q].present? ? 'people.firstname, people.lastname ASC' : 'application_for_offerings.ID DESC'

    @scholars = @search.result
                  .eager_load(:person, {offering: :quarter_offered})
                  .page(params[:page])
                  .order(order_clause)

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

  def fetch_campus
    @campus = ApplicationForOffering.awardees_campus_mapping
  end
  
  private 
  
  def find_by_mentor_name(keyword)
    @mge_awardees
      .eager_load(mentors: :person)
      .where("application_mentors.primary = 1 AND CONCAT_WS(' ', people.firstname, people.lastname) LIKE ?", "%#{keyword}%")
      .order("people.firstname, people.lastname")
  end
  
end