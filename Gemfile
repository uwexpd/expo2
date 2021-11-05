source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 5.2', '>= 5.2.4.3'
gem 'sass-rails'
gem 'coffee-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 4.2'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
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
# gem 'activeadmin_dynamic_fields'

# hardens your app against XSS attack
gem 'secure_headers'

# handle multiple primary keys in UWSDB tables: Since many UWSDB tables have multiple primary keys and Rails doesn't really "do" composite PK's
gem 'composite_primary_keys', '~> 11.3', '>= 11.3.1'

# adapter for ms sql server 2012
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter', '~> 5.2.1'

# Connect to UW Student Web Service
gem 'activeresource', '~> 5.1', '>= 5.1.1'

gem 'mysql2', '~> 0.5.0'
gem 'activerecord-userstamp', github: 'lowjoel/activerecord-userstamp'
gem 'tinymce-rails'
gem 'will_paginate', '~> 3.1.6'
gem 'will_paginate-materialize', github: 'harrybournis/will_paginate-materialize'
gem 'rails_autolink'

# for chosen
gem 'chosen-rails'

gem 'breadcrumbs_on_rails', '~> 4.0'
#gem 'paranoia' TODO
gem 'json'
# gem 'activesupport-json_encoder' TODO check if still needed this
gem 'nokogiri'
gem 'spreadsheet'

# Error reporting
gem 'sentry-raven'

gem 'chartkick'
#gem 'groupdate'

gem 'sanitize'
gem 'capitalize-names'
# gem 'auto_strip_atrributes'

# material ui
gem 'material_icons'
gem 'materialize-sass', '~> 1.0.0'

# backport from Rails 5 for Rails 4.2
# gem 'where-or' #TODO comment out this since upgrade to rails 5

gem 'byebug'
gem 'delayed_job', '~> 4.1', '>= 4.1.8'
gem 'delayed_job_active_record', '~> 4.1', '>= 4.1.4'
gem "active_admin_import" , github: "activeadmin-plugins/active_admin_import"

gem 'dotenv-rails'
gem 'recaptcha'
gem 'invisible_captcha', '~> 1.1'

# for mutliple database
gem 'multiverse'

group :production do  
  gem 'omniauth-shibboleth'
end

group :development, :test do  
  gem 'awesome_print'
  gem 'rspec-rails'  
end

group :development do
  gem 'puma'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'capistrano', '~> 3.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'annotate'  
  gem 'brakeman', :require => false
  gem 'uw_sws'
  gem 'rack-mini-profiler', require: false
  gem 'spring-commands-rspec'  
  #gem 'gas_load_tester'  
end

  
