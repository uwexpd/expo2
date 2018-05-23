set :stage, :production

set :deploy_to, '/usr/local/apps/expo2'
set :repo_url,  'git@github.com:uwexpd/expo2.git'
set :scm, 'git'
set :branch, 'master'
set :deploy_user, 'joshlin'
server 'expd.uaa.washington.edu', user: 'joshlin', roles: %w{web app db}, primary: true
set :rvm_ruby_version, '2.3.1' # set up which rvm ruby to use in server
# Setup multiple rubies to run same version of phusion passenger: https://www.phusionpassenger.com/library/indepth/ruby/multiple_rubies.html
set :passenger_environment_variables, { :path => '/home/joshlin/.rvm/gems/ruby-1.8.7-head/gems/passenger-5.1.11/bin:$PATH' }
set :passenger_restart_command, 'rvm-exec 1.8.7@default ruby -S passenger-config restart-app'

# Tell cap your own private keys for git and use agent forwarding with this command.
set :ssh_options, {
  forward_agent: true
}

set :keep_releases, 10

# files we want symlinking to specific entries in shared.
set :linked_files, %w{config/email.yml config/database.yml config/database_scholarships.yml}

# dirs we want symlinking to shared
set :linked_dirs, %w{config/certs public/expo/error_images}

set :assets_prefix, 'expo/assets'
  
namespace :deploy do
  task :fix_absent_manifest_bug do
     on roles(:web) do
       within release_path do execute :touch,
         release_path.join('public/expo/assets/manifest-fix.temp')
       end
     end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  
end

after 'deploy:assets:precompile', 'deploy:fix_absent_manifest_bug'
