module ActiveAdmin
  module ResourceController::DataAccess
    def apply_filtering(chain)
      filter_params = params[:q] || {}

      filter_params.each do |key, value|
        filter_params[key] = value.strip if value.class == String
      end

      @search = chain.ransack(filter_params || {})
      @search.result
    end
  end
end