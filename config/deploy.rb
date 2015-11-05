require 'capistrano-passenger'

# passenger once had only one way to restart: `touch tmp/restart.txt`
# Beginning with passenger v4.0.33, a new way was introduced: `passenger-config restart-app`
# 
# The new way to restart is not so practical for everyone, since it may require your deployment user to have sudo access.
# While we eagerly await the release of passenger v5.0.10, which will make the new method possible without sudo access,
# we recognize that not everyone is ready for this change yet.
# 
# capistrano-passenger gives you the flexibility to choose your restart approach, or to rely on reasonable defaults.
# 
# If you want to restart using `touch tmp/restart.txt`, add this to your config/deploy.rb:
# 
#     set :passenger_restart_with_touch, true
# 
# If you want to restart using `passenger-config restart-app`, add this to your config/deploy.rb:
# 
#     set :passenger_restart_with_touch, false # Note that `nil` is NOT the same as `false` here
# 
# If you don't set `:passenger_restart_with_touch`, capistrano-passenger will check what version of passenger you are running
# and use `passenger-config restart-app` if it is available in that version.
# 
# If you are running passenger in standalone mode, it is possible for you to put passenger in your
# Gemfile and rely on capistrano-bundler to install it with the rest of your bundle.
# If you are installing passenger during your deployment AND you want to restart using `passenger-config restart-app`,
# you need to set `:passenger_in_gemfile` to `true` in your `config/deploy.rb`.
