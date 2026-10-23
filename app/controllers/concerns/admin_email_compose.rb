module AdminEmailCompose
  private

  # A short link for a view; records can be an ActiveRecord relation or an array.
  def email_write_path_for(records)
    recipients = records.is_a?(ActiveRecord::Relation) ? records.to_a : Array.wrap(records).flatten.compact
    return nil if recipients.empty?

    select = recipients.group_by { |recipient| recipient.class.name }
                       .transform_values { |group| group.map(&:id).uniq }
    token = AdminEmailSelection.store!(user: current_user, select: select)
    admin_email_write_path(email_selection_token: token)
  end

  def redirect_to_email_write(records, fallback_location: admin_root_path, require_email: true)
    if require_email
      records = records.is_a?(ActiveRecord::Relation) ? records.to_a : Array.wrap(records).flatten.compact
      # Match the compose view: use the recipient's email, or their person's
      # email only when the recipient does not expose an email method.
      records = records.select do |recipient|
        address = recipient.respond_to?(:email) ? recipient.email : recipient.person&.email
        address.present?
      end
    end

    path = email_write_path_for(records)
    if path
      redirect_to path
    else
      message = require_email ? "None of the selected recipients has an email address." : "No email recipients were found."
      redirect_back fallback_location: fallback_location, alert: message
    end
  end
end
