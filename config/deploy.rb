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

set :stage, :production

set :application, "expo2"
set :deploy_to, "/usr/local/apps/expo2"
set :repo_url,  "git@github.com:uwexpd/expo2.git"
set :scm, "git"
set :branch, 'master'
set :deploy_user, "joshlin"
server 'expd.uaa.washington.edu', user: 'joshlin', roles: %w{web app db}, primary: true
set :rvm_ruby_version, "2.3.1" # set up which rvm ruby to use in server

# Tell cap your own private keys for git and use agent forwarding with this command.
set :ssh_options, {
  forward_agent: true
}

#set :pty, true # Must be set for the password prompt from git to work

set :keep_releases, 10

# files we want symlinking to specific entries in shared.
set :linked_files, %w{config/database.yml}

# dirs we want symlinking to shared
set :linked_dirs, %w{config/certs}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
end

# Note that this only work on Mac
namespace :deploy do
  desc 'Sends a message when deployment is completed'
  task :notify do
    system("\\say Capistrano Deployment Completed!")
  end
end

after "deploy:finished", "deploy:notify"
