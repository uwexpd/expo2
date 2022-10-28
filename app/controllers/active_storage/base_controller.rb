# frozen_string_literal: true

# The base class for all Active Storage controllers.
class ActiveStorage::BaseController < ActionController::Base
  
  include AuthenticatedSystem
  before_action :login_required, :except => :remove_vicarious_login
  before_action :set_stamper

  protect_from_forgery with: :exception

  before_action do
    ActiveStorage::Current.host = request.base_url
  end

  private

  def set_stamper
    @_userstamp_stamper = ActiveRecord::Userstamp.config.default_stamper_class.stamper
    ActiveRecord::Userstamp.config.default_stamper_class.stamper = @current_user
  end
  
end