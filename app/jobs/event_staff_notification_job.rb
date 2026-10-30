class EventStaffNotificationJob < ApplicationJob
  queue_as :default

  def perform(info, recipient)
    Rails.logger.debug do
      "EventStaffNotificationJob arguments: info_class=#{info.class}, " \
        "info=#{info.inspect}, recipient=#{recipient.inspect}"
    end

    template = EmailTemplate.find_by_name('event staff admin notification')
    unless template
      Rails.logger.warn('Missing EmailTemplate: event staff notification')
      return
    end

    template.create_email_to(info, '', recipient).deliver_now
  end
end
