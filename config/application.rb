require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Expo2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = false

    # Do not swallow errors in after_commit/after_rollback callbacks. # This is deprecated in rails 5
    # config.active_record.raise_in_transactional_callbacks = true

    # Be sure to have the adapter's gem in your Gemfile and follow the adapter's specific installation
    config.active_job.queue_adapter = :delayed_job
    
    # Allow for models or class in subdirectories off models and expo lib
    config.eager_load_paths += Dir["#{config.root}/app/models/**/"]
    config.eager_load_paths += Dir["#{config.root}/lib/expo/**/"]
    
    config.constants = config_for(:constants)
    
    config.relative_url_root = '/expo'
    config.assets.prefix = '/expo/assets'
    
    config.generators do |g|
       g.test_framework :rspec,
         fixtures: false,
         view_specs: false,
         helper_specs: false,
         routing_specs: false
    end

    Raven.configure do |config|
      config.dsn = "https://1201e893bd9f46a3a7487bbef67f62f1:ba372b40539a4d4d902fd6afeba23ee2@sentry.io/207047"
      config.environments = ['staging', 'production']
    end

  end
end
