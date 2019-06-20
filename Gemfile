# git_source(:github) { |repo| "https://github.com/#{repo}.git" } # Didn't work in production...TODO: try to fix this later
source 'https://rubygems.org'

gem 'rails', '~> 4.2', '> 4.2.8'
gem 'sass-rails'
gem 'coffee-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'turbolinks'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# automates cross-browser CSS compatibility
gem 'autoprefixer-rails'

# Active Admin
gem 'activeadmin'
gem 'ransack' # successor of meta search for rails 4
gem 'active_material', github: 'vigetlabs/active_material'
gem 'activeadmin_addons'

# hardens your app against XSS attack
#gem 'secure_headers', '>= 2.1.0'

# handle multiple primary keys in UWSDB tables: Since many UWSDB tables have multiple primary keys and Rails doesn't really "do" composite PK's
gem 'composite_primary_keys', '>=8.1.1'

# adapter for ms sql server 2012
gem 'tiny_tds', '~> 0.7.0'
gem 'activerecord-sqlserver-adapter', '~> 4.2.0'

# Connect to UW Student Web Service
gem 'activeresource', require: 'active_resource'

gem 'mysql2', '~> 0.4.0'
gem 'activerecord-userstamp'
gem 'tinymce-rails'
gem 'will_paginate', '~> 3.1.6'
gem 'will_paginate-materialize', github: 'harrybournis/will_paginate-materialize'
gem 'rails_autolink'

# for chosen
gem 'chosen-rails'

gem 'breadcrumbs_on_rails'
#gem 'paranoia', github: 'rubysherpas/paranoia', branch: 'rails4'
gem 'json'
gem 'activesupport-json_encoder'
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
gem 'where-or'

gem 'invisible_captcha'

group :production do  
  gem 'omniauth-shibboleth'
end

group :development, :test do
  gem 'byebug'
  gem 'awesome_print'
  gem "rspec-rails"
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'capistrano', '~> 3.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'annotate'
  gem 'thin', :require => false
  gem 'brakeman', :require => false
  gem 'uw_sws'
  gem 'rack-mini-profiler', require: false
  gem 'spring-commands-rspec'  
end

  


