class ScholarshipFavoritesController < ApplicationController
  skip_before_action :login_required, raise: false
  before_action :require_login

  def create
    favorite = current_user.scholarship_favorites.find_or_initialize_by(
      scholarship_id: params[:scholarship_id]
    )

    if favorite.save
      respond_to do |format|
        format.html { redirect_back fallback_location: scholarships_path }
        format.json { render json: { favorited: true } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: scholarships_path }
        format.json { render json: { favorited: false, errors: favorite.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    favorite = current_user.scholarship_favorites.find_by(scholarship_id: params[:id])
    favorite&.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: scholarships_path }
      format.json { render json: { favorited: false } }
    end
  end

  private

  def require_login
    unless logged_in?
      # Store the return path so we can redirect back after login
      session[:return_to] = request.referer
      respond_to do |format|
        format.html { redirect_to login_path }
        format.json { render json: { redirect: login_path }, status: :unauthorized }
      end
    end
  end
end
