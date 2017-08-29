source 'https://rubygems.org'

gem 'rails', '~> 4.2', '> 4.2.8'
gem 'sass-rails'
gem 'coffee-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'foundation-icons-sass-rails'
gem 'foundation-rails' 

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# automates cross-browser CSS compatibility
#gem "autoprefixer-rails", ">= 5.0.0.1"

# Active Admin
gem 'activeadmin'
gem 'ransack' # successor of meta search for rails 4
gem 'active_material', github: 'vigetlabs/active_material'

# hardens your app against XSS attack
#gem 'secure_headers', '>= 2.1.0'

# handle multiple primary keys in UWSDB tables: Since many UWSDB tables have multiple primary keys and Rails doesn't really "do" composite PK's
gem "composite_primary_keys", '>=8.1.1'

# adapter for ms sql server 2012
gem 'tiny_tds', '~> 0.7.0'
gem 'activerecord-sqlserver-adapter', '~> 4.2.0'

# Connect to UW Student Web Service
gem 'activeresource', require: 'active_resource'

gem 'mysql2'
gem 'activerecord-userstamp'
gem 'tinymce-rails'
gem 'will_paginate'
gem 'will_paginate-foundation'
gem 'rails_autolink'

# for chosen
gem 'compass-rails'
gem 'chosen-rails'
gem 'jquery-turbolinks'

gem 'breadcrumbs_on_rails'
#gem "paranoia", github: "rubysherpas/paranoia", branch: "rails4"
gem 'json'
gem 'activesupport-json_encoder'
gem 'nokogiri'
gem 'spreadsheet'

# Error reporting
gem 'sentry-raven'


group :production do  
  gem "omniauth-shibboleth"
end

group :development, :test do
  gem 'byebug'
  gem 'awesome_print'  
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
  gem 'uw_sws'
end

  


