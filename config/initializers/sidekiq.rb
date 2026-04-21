# In development/test we default to local Redis for convenience.
# In production we require REDIS_URL to be set so we don't accidentally use localhost.
if defined?(Dotenv)
  Dotenv.overload(Rails.root.join(".env")) if File.exist?(Rails.root.join(".env"))
end

redis_url =
  if Rails.env.production?
    ENV.fetch("REDIS_URL") # fail fast if missing
  else
    ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")
  end

redis_config = {
  url: redis_url,
  network_timeout: 5
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end