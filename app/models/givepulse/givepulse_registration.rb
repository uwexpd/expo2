class GivepulseRegistration < GivepulseBase
  include ActiveModel::Model

  # == Attributes ==
  # Based on the API fields for Registrations
  attr_accessor :id, :created, :modified, :user_id, :group_id, :event_id,
                :status, :start_date_time, :end_date_time,
                :registration_source, :group_reservation,
                :user, :event, :group

  # == Query ==
  # Example:
  # GivepulseRegistration.where(group_id: 127821, status: ['Registered'])
  #
  def self.where(attributes)
    begin
      response = request_api('/registrations', attributes, method: :get)
      parsed = JSON.parse(response.body)

      if parsed['total'].to_i > 0
        parsed['results'].map { |attrs| new(attrs.slice(*permitted_attrs)) }
      else
        Rails.logger.warn("No registrations found with attributes: #{attributes}")
        []
      end
    rescue StandardError => e
      Rails.logger.error("Error fetching registrations: #{e.message}")
      []
    end
  end

  # == Update ==
  # Update a registration, e.g., to cancel it.
  #
  # Example:
  # reg = GivepulseRegistration.new(id: 507151)
  # reg.cancel!(send_notification: true)
  #
  def update(params)
    return false unless id

    begin
      response = GivepulseRegistration.request_api('/registrations', params.merge(registration_id: id), method: :put)
      parsed = JSON.parse(response.body)

      if response.code.to_i == 200 && parsed['message'].to_s.include?('success')
        Rails.logger.info("Successfully updated registration #{id}: #{parsed['message']}")
        parsed
      else
        Rails.logger.warn("Failed to update registration #{id}: #{response.body}")
        nil
      end
    rescue StandardError => e
      Rails.logger.error("Error updating registration #{id}: #{e.message}")
      nil
    end
  end

  # == Cancel Registration ==
  # Cancels a registration by ID.
  #
  # Example:
  # reg.cancel!(send_notification: true)
  #
  def cancel!(send_notification: false)
    return false unless id

    update(
      notification: send_notification ? 1 : 0,
      status: 'cancel'
    )
  end

  # == Class Method: Cancel by ID ==
  # Convenience method for canceling a registration directly
  #
  # Example:
  # GivepulseRegistration.cancel_registration(507151)
  #
  def self.cancel_registration(registration_id, send_notification: false)
    begin
      response = request_api(
        '/registrations',
        {
          registration_id: registration_id,
          notification: send_notification ? 1 : 0,
          status: 'cancel'
        },
        method: :put
      )

      parsed = JSON.parse(response.body)

      if response.code.to_i == 200 && parsed['message'].to_s.include?('success')
        Rails.logger.info("Successfully canceled registration #{registration_id}: #{parsed['message']}")
        parsed
      else
        Rails.logger.warn("Failed to cancel registration #{registration_id}: #{response.body}")
        nil
      end
    rescue StandardError => e
      Rails.logger.error("Error canceling registration #{registration_id}: #{e.message}")
      nil
    end
  end

end
