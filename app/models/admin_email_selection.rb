# Configure Rails.cache as a shared cache in production (Redis/Memcached).
class AdminEmailSelection
  TTL = 1.hour

  def self.store!(user:, select:)
    token = SecureRandom.urlsafe_base64(32)
    saved = Rails.cache.write(
      key(token),
      { user_id: user.id, select: select },
      expires_in: TTL
    )
    raise "Could not save email selection" unless saved

    token
  end

  def self.fetch(user:, token:)
    return nil unless token.to_s.match?(/\A[A-Za-z0-9_-]{43}\z/)

    value = Rails.cache.read(key(token))
    return nil unless value && value[:user_id] == user.id

    value[:select]
  end

  def self.delete(token:)
    Rails.cache.delete(key(token))
  end

  def self.key(token)
    "admin_email_selection:v1:#{token}"
  end
  private_class_method :key
end