class ScholarshipsController < ApplicationController
  unit = Unit.find_by_abbreviation('omsfa')
  add_breadcrumb unit.name, unit.home_url

  skip_before_action :login_required, :add_to_session_history, raise: false

  def index
    selected_standings    = []
    selected_citizenships = []

    if params[:q]
      # ── Categories: include sub-categories ────────────────────────────────
      selected_categories = params[:q][:scholarship_categories_category_id_in]&.reject(&:blank?)
      unless selected_categories.blank?
        categories_with_sub = selected_categories + selected_categories.flat_map do |category_id|
          Category.find(category_id).sub_categories.map { |s| s.id.to_s }
        end
        params[:q][:scholarship_categories_category_id_in] = categories_with_sub
      end

      # ── Work on a COPY so params[:q] stays intact for form re-rendering ───
      # If we delete directly from params[:q], the hidden Ransack checkboxes
      # will be unchecked on the next render and Select2 won't restore state.
      q_for_ransack = params[:q].deep_dup

      # ── Academic Standing: pull out for OR logic ───────────────────────────
      standing_fields    = %w[freshman sophomore junior senior fifth_year graduate]
      selected_standings = standing_fields.select { |f| q_for_ransack["#{f}_true"] == '1' }
      standing_fields.each { |f| q_for_ransack.delete("#{f}_true") }

      # ── Citizenship: same OR fix ───────────────────────────────────────────
      citizenship_fields    = %w[us_citizen permanent_resident other_visa_status hb_1079]
      selected_citizenships = citizenship_fields.select { |f| q_for_ransack["#{f}_true"] == '1' }
      citizenship_fields.each { |f| q_for_ransack.delete("#{f}_true") }
    end

    # ── Build the correct base scope, then apply OR conditions ────────────────
    base_scope = if params[:scope] == 'upcoming'
      Scholarship.upcoming
    elsif params[:scope] == 'favorites' && logged_in?
      favorite_ids = current_user.scholarship_favorites.pluck(:scholarship_id)
      Scholarship.active.where(id: favorite_ids)
    else
      Scholarship.active
    end

    base_scope = apply_or_filters(base_scope, selected_standings, selected_citizenships)

    # Use the sanitized copy (q_for_ransack) so Ransack doesn't AND the standing
    # and citizenship fields — but params[:q] is still untouched for form state.
    @search = base_scope.ransack(q_for_ransack || params[:q])

    @scholarships = @search.result(distinct: true)
                           .includes(:scholarship_deadlines)
                           .page(params[:page])
                           .order('scholarships.title')

    # Count for the Favorites tab badge — 0 if not logged in
    @favorites_count = logged_in? ? current_user.scholarship_favorites.count : 0

    add_breadcrumb "Scholarships Search"
  end

  def show
    add_breadcrumb "Scholarships Search", scholarships_path

    if params[:page_stub]
      @scholarship = Scholarship.find_by_page_stub(params[:page_stub])

      if @scholarship
        unless @scholarship.is_active?
          flash[:alert] = "The scholarship, #{@scholarship.title}, is inactive. You are not able to see the details."
          redirect_to action: 'index'
        end

        @is_favorited = logged_in? && current_user.scholarship_favorites.exists?(scholarship_id: @scholarship.id)
        add_breadcrumb @scholarship.title
      else
        flash[:alert] = "Cannot find the scholarship."
        redirect_to action: 'index'
      end
    end
  end

  private

  # Applies Academic Standing and Citizenship as OR conditions to any scope.
  #
  # Examples:
  #   Freshman + Sophomore  → WHERE (freshman = 1 OR sophomore = 1)
  #   US Citizen + Perm Res → WHERE (us_citizen = 1 OR permanent_resident = 1)
  #   Both selected         → WHERE (freshman = 1 OR sophomore = 1)
  #                             AND (us_citizen = 1 OR permanent_resident = 1)
  #
  # Each GROUP is still AND-ed with the other (standing AND citizenship),
  # but selections within the same group are OR-ed.
  def apply_or_filters(scope, standings, citizenships)
    if standings.present?
      scope = scope.where(standings.map { |f| "(#{f} = 1)" }.join(' OR '))
    end
    if citizenships.present?
      scope = scope.where(citizenships.map { |f| "(#{f} = 1)" }.join(' OR '))
    end
    scope
  end
end
