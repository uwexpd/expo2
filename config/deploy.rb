# config/deploy.rb — Shared configuration for ALL stages
# Stage-specific settings (deploy_to, branch, server, etc.) live in config/deploy/<stage>.rb

set :repo_url,         'git@github.com:uwexpd/expo2.git'
set :rails_env,        :production
set :bundle_flags,     "--quiet"
set :deploy_user,      'joshlin'
set :rvm_ruby_version, '3.0.6'

set :default_env, {
  'SSL_CERT_FILE' => '/etc/ssl/certs/ca-certificates.crt'
}

set :ssh_options, {
  forward_agent: true
}

# Files we want symlinking to specific entries in shared.
set :linked_files, %w{
  .env
  config/email.yml
  config/database.yml
  config/master.key
}

# Dirs we want symlinking to shared
set :linked_dirs, %w{bin log files tmp/pids tmp/cache tmp/sockets vendor/bundle public/system config/certs public/expo/error_images}

namespace :deploy do
  # Workaround for missing asset manifest bug in Rails assets pipeline
  task :fix_absent_manifest_bug do
    on roles(:web) do
      within release_path do
        execute :touch, release_path.join('public/assets/manifest-fix.temp')
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
      # Uses :sidekiq_service_unit_name set per stage — skipped silently if no :sidekiq role
      execute :sudo, "-n", "/usr/bin/systemctl", :restart, fetch(:sidekiq_service_unit_name)
    end
  end

  desc "Show Sidekiq status via systemd"
  task :sidekiq_status do
    on roles(:sidekiq) do
      execute :sudo, "-n", "/usr/bin/systemctl", :status, fetch(:sidekiq_service_unit_name)
    end
  end
end

after 'deploy:assets:precompile', 'deploy:fix_absent_manifest_bug'
after 'deploy:published',         'custom:restart_sidekiq'
