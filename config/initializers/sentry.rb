Sentry.init do |config|
  config.dsn = ENV.fetch("SENTRY_DNS")
  
  config.enabled_environments = %w[production]

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  # config.traces_sample_rate = 0.25 #[TODO] sentry cannot find ca file...need to be fixed
  # or
  # config.traces_sampler = lambda do |context|
  #   true
  # end

  # Enable to send senstive info like user ip, user cookie, request body, and query string
  config.send_default_pii = true
  

end