# # config/deploy/production.rb

# require 'capistrano/rake'
# set :stage, :production

# set :deploy_to, '/usr/local/apps/expo2'
# set :repo_url,  'git@github.com:uwexpd/expo2.git'
# set :branch, 'master'
# set :rails_env, :production
# set :bundle_flags, "--quiet"
# set :deploy_user, 'joshlin'
# set :rvm_ruby_version, '2.7.2'

# server 'new.expo.uw.edu', user: 'joshlin', roles: %w{web app db}, primary: true

# set :ssh_options, {
#   forward_agent: true
# }

# set :keep_releases, 10

# # Files that should be symlinked from shared to current release
# set :linked_files, %w[
#   config/email.yml
#   config/database.yml
#   config/master.key
# ]

# # Directories that should be symlinked from shared to current release
# set :linked_dirs, %w[
#   bin
#   log
#   files
#   tmp/pids
#   tmp/cache
#   tmp/sockets
#   vendor/bundle
#   public/system
#   config/certs
#   public/expo/error_images
# ]

# namespace :deploy do
#   # Fix missing manifest bug in some Rails versions
#   task :fix_absent_manifest_bug do
#     on roles(:web) do
#       within release_path do
#         execute :touch, release_path.join('public/assets/manifest-fix.temp')
#       end
#     end
#   end

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       execute :touch, release_path.join('tmp/restart.txt')
#     end
#   end
# end

# after 'deploy:assets:precompile', 'deploy:fix_absent_manifest_bug'