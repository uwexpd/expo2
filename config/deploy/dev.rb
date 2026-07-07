set :stage, :development

set :deploy_to, '/usr/local/apps/expo_dev'
set :branch,    'migrate-database'
set :keep_releases, 3

server 'new.expo.uw.edu', user: 'joshlin', roles: %w{web app db}, primary: true

# NOTE: Sidekiq role excluded — sharing the same server instance as production.
#       If you need a separate sidekiq for dev, add :sidekiq to roles above
#       and create a new systemd service (e.g. sidekiq-expo-dev.service).
