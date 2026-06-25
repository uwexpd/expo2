set :stage, :production

set :deploy_to, '/usr/local/apps/expo'
set :repo_url,  'git@github.com:uwexpd/expo2.git'
set :branch, 'upgrade/ruby3.0.6-rails6.1'
set :rails_env, :production
set :bundle_flags, "--quiet"
set :deploy_user, 'joshlin'
server 'new.expo.uw.edu', user: 'joshlin', roles: %w{web app db sidekiq}, primary: true
set :rvm_ruby_version, '3.0.6'  # ← update this to your Ruby 3 version
# sidekiq service config is at:/etc/systemd/system/sidekiq-expo.service in server
set :sidekiq_service_unit_name, "sidekiq-expo"

# for dev.expo.uw.edu
set :default_env, {
  'SSL_CERT_FILE' => '/etc/ssl/certs/ca-certificates.crt'  
}

# Tell cap your own private keys for git and use agent forwarding with this command.
set :ssh_options, {
  forward_agent: true
}

set :keep_releases, 10

# files we want symlinking to specific entries in shared.
set :linked_files, %w{
  .env
  config/email.yml
  config/database.yml
  config/master.key
}

# dirs we want symlinking to shared
set :linked_dirs, %w{bin log files tmp/pids tmp/cache tmp/sockets vendor/bundle public/system config/certs public/expo/error_images}

# set :assets_prefix, 'expo/assets'
  
namespace :deploy do
  task :fix_absent_manifest_bug do
     on roles(:web) do
       within release_path do execute :touch,
         release_path.join('public/assets/manifest-fix.temp')
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

namespace :custom do
  desc "Restart Sidekiq via systemd"
  task :restart_sidekiq do
    on roles(:sidekiq) do
      execute :sudo, "-n", "/usr/bin/systemctl", :restart, "sidekiq-expo2"
    end
  end

  desc "Show Sidekiq status via systemd"
  task :sidekiq_status do
    on roles(:sidekiq) do
      execute :sudo, "-n", "/usr/bin/systemctl", :status, "sidekiq-expo2"
    end
  end
end

after 'deploy:assets:precompile', 'deploy:fix_absent_manifest_bug'
after "deploy:published", "custom:restart_sidekiq"
