source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 6.1.7'
gem 'sass-rails', '>= 6'
gem 'coffee-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 4.2'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# automates cross-browser CSS compatibility
gem 'autoprefixer-rails'

# Active Admin
gem 'activeadmin', '~> 2.7'
gem 'ransack', '~> 2.3', '>= 2.3.2'
gem 'active_material', '~> 1.5', '>= 1.5.2'
gem 'activeadmin_addons'
gem "active_admin_import" , github: "activeadmin-plugins/active_admin_import"
# gem 'activeadmin_dynamic_fields'

# hardens your app against XSS attack
gem 'secure_headers'

# handle multiple primary keys in UWSDB tables: Since many UWSDB tables have multiple primary keys and Rails doesn't really "do" composite PK's
gem 'composite_primary_keys', '~> 13.0'

# adapter for ms sql server 2012
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter', '~> 6.1'

# Connect to UW Student Web Service
gem 'activeresource', '~> 5.1', '>= 5.1.1'

gem 'mysql2', '~> 0.5.5'
gem 'mimemagic', '~> 0.4.3'
gem 'activerecord-userstamp', github: 'Coursemology/activerecord-userstamp'
gem 'tinymce-rails', '5.10.7' # [TODO] not working with verson 6+
gem 'will_paginate', '~> 4.0'
# gem 'will_paginate-materialize', git: 'https://github.com/mldoscar/will_paginate-materialize', branch: 'master'

# For smoothing the upgrade since auto_link and textilize are deprecated
gem 'rails_autolink'
gem 'textilize'

gem 'chosen-rails'

gem 'breadcrumbs_on_rails', '~> 4.0'
#gem 'paranoia' TODO
gem 'json'
# gem 'activesupport-json_encoder' TODO check if still needed this
gem 'nokogiri'
gem 'spreadsheet'

# Error reporting
gem 'sentry-ruby'
gem "sentry-rails"

gem 'chartkick'
#gem 'groupdate'

gem 'sanitize'
gem 'capitalize-names'
gem 'email_validator'
# gem 'auto_strip_atrributes'

gem 'material_icons', '~> 4.0'
gem 'materialize-sass', '~> 1.0.0'

gem 'redis'
gem "sidekiq", "~> 6.5"

gem 'dotenv-rails'
gem 'recaptcha'
gem 'invisible_captcha', '~> 1.1'

gem 'multiverse' # Mutliple database

gem 'carrierwave', '~> 2.0'
gem 'mini_magick'

gem 'hexapdf', '0.26.2' # PDF generation, manipulation, merging, etc
gem 'wicked_pdf' # html to pdf
# gem 'wkhtmltopdf-binary'

gem 'sdoc'
gem 'rdoc'

gem "select2-rails"
gem 'leaflet-rails'

# gem 'zip'
gem 'rubyzip'
gem 'caxlsx'
gem 'caxlsx_rails'

gem 'activeadmin_reorderable'
gem 'acts_as_list'

# Upgrading to ruby 3
gem 'mutex_m'
# Locking Psych < 4 to avoid `aliases: true` YAML error in Rails 5.2
gem 'psych', '< 4'
gem 'concurrent-ruby', '1.3.4'

group :production do  
  gem 'omniauth-shibboleth'
end

group :development, :test do
  gem 'awesome_print'
  gem 'rspec-rails'
  gem 'byebug'
  gem 'pry', '~> 0.14.2'
end

group :development do
  gem 'puma'
  gem 'web-console', '~> 4.0'  
  gem 'spring', '~> 3.1', '>= 3.1.1'
  gem 'capistrano', '~> 3.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-rake', require: false
  gem 'annotate'  
  gem 'brakeman', :require => false  
  gem 'rack-mini-profiler', require: false
  gem 'spring-commands-rspec'  
  # gem 'gas_load_tester'
  gem 'ed25519', '>= 1.2', '< 2.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'  
  # gem 'meta_request'
  gem 'httparty'
end
