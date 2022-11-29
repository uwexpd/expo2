Sentry.init do |config|
  config.dsn = "https://1201e893bd9f46a3a7487bbef67f62f1@o94732.ingest.sentry.io/207047"
  
  config.enabled_environments = %w[production]

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end

  # Enable to send senstive info like user ip, user cookie, request body, and query string
  config.send_default_pii = true
  

end