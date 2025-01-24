module ActiveAdmin
  module ResourceController::DataAccess
    def apply_filtering(chain)

      filter_params = params[:q] || {}

      filter_params.each do |key, value|
        filter_params[key] = value.strip if value.class == String
      end

      # if chain.blank?
        #logger.debug "Debug: chain is empty #{chain.inspect}"
        # return chain # Return empty chain to avoid errors and let ActiveAdmin handle the blank slate
      # end

      @search = chain.ransack(filter_params || {})
      # logger.debug "Debug search: #{@search.inspect}"
      # logger.debug "Debug result: #{@search.result.inspect}"
      @search.result
    end
  end
end