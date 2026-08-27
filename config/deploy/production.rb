# config/deploy/production.rb — Production stage configuration

set :stage,    :production
set :deploy_to, '/usr/local/apps/expo'
set :branch, 'master' #'upgrade/ruby3.0.6-rails6.1'

set :keep_releases, 10

server 'new.expo.uw.edu', user: 'joshlin', roles: %w{web app db sidekiq}, primary: true

# sidekiq service config: /etc/systemd/system/sidekiq-expo.service
set :sidekiq_service_unit_name, "sidekiq-expo"
