Rails.application.routes.default_url_options = { host: 'localhost', port: 3000 }

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  # For Debug need
  # config.cache_store = :file_store, "#{Rails.root}/tmp/cache"
  # config.action_controller.enable_fragment_cache_logging = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  
  # show logs for console and rake tasks
  # config.logger = Logger.new(STDOUT)


  # ActionMailer Config
  config.action_mailer.perform_deliveries = false # Set it to true to send the email in dev mode  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => "localhost:3000" }
  config.action_mailer.smtp_settings = YAML.load_file("#{Rails.root}/config/email.yml")[Rails.env].symbolize_keys

  # Setting this option to false tells Rails to show error pages, rather than the stack traces it normally shows in development mode
  # config.consider_all_requests_local = false # this is only for testing

  # Store files locally.
  config.active_storage.service = :local

end
