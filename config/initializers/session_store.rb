# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: '_expo2_session',
  expire_after: 2.days
  # domain: :all,
  # same_site: :none,  # Required if cross-site requests are needed
  # secure: true,      # Required when same_site: :none is set
  # tld_length: 2