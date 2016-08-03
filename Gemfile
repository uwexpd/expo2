source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6', git: "git://github.com/rails/rails.git", branch: '4-2-stable'
gem 'sass-rails'
gem 'foundation-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# automates cross-browser CSS compatibility
#gem "autoprefixer-rails", ">= 5.0.0.1"

# Active Admin
gem 'activeadmin', github: 'activeadmin'
gem 'ransack' # successor of meta search for rails 4

# hardens your app against XSS attack
#gem 'secure_headers', '>= 2.1.0'

# handle multiple primary keys in UWSDB tables: Since many UWSDB tables have multiple primary keys and Rails doesn't really "do" composite PK's
gem "composite_primary_keys", '>=8.1.1'
# adapter for ms sql server 2012
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter', '~> 4.2.0'

gem 'activeresource', require: 'active_resource'

gem 'mysql2'
gem 'activerecord-userstamp'
gem 'tinymce-rails'
gem 'will_paginate'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'awesome_print'  
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'capistrano'
  gem 'capistrano-passenger'
  gem 'annotate'
end

group :development do 
  #gem 'thin', :require => false
end  

group :test do
end



  


