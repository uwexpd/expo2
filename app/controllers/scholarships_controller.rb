class ScholarshipsController < ApplicationController

  def index
    @search = Scholarship.ransack(params[:q])
    @scholarships = @search.result.includes(:scholarship_type).page(params[:page])
  end
  
end