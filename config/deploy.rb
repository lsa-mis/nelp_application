# config valid for current version and patch releases of Capistrano
lock "~> 3.15.0"
set :rbenv_type, :user
set :rbenv_ruby, '2.7.2'
set :user, "deployer"
set :application, "nelp_application"
set :repo_url, "git@github.com:lsa-mis/nelp_application.git"
set :puma_threads,    [4, 16]
set :puma_workers,    0
# set :branch, 'master'
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# Default value for keep_releases is 5
set :keep_releases, 2

# If the environment differs from the stage name
set :rails_env, 'production'

set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
# Avoid permissions issues with using /tmp
set :tmp_dir, '/home/deployer/tmp'
# set :assets_roles, [:web, :app]

# Defaults to 'assets'
# This should match config.assets.prefix in your rails config/application.rb
# set :assets_prefix, 'packs'

# Defaults to ["/path/to/release_path/public/#{fetch(:assets_prefix)}/.sprockets-manifest*", "/path/to/release_path/public/#{fetch(:assets_prefix)}/manifest*.*"]
# This should match config.assets.manifest in your rails config/application.rb
# set :assets_manifests, ['app/assets/config/manifest.js']
# set :assets_manifests, ['app/javascript/packs/application.js']

# RAILS_GROUPS env value for the assets:precompile task. Default to nil.
# set :rails_assets_groups, :assets

# Defaults to nil (no asset cleanup is performed)
# If you use Rails 4+ and you'd like to clean up old assets after each deploy,
# set this to the number of versions to keep
set :keep_assets, 2


# set :nginx_sites_available_path, "/etc/nginx/sites-available"
# set :nginx_sites_enabled_path, "/etc/nginx/sites-enabled"
# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true


# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
# While migrations looks like a concern of the database layer, Rails migrations are strictly 
# related to the framework. Therefore, it's recommended to set the role to :app instead of 
# :db like:
set :migration_role, :app

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

# namespace :check do
#   before :linked_files, :set_master_key do
#     on roles(:app), in: :sequence, wait: 10 do
#       unless test("[ -f #{shared_path}/config/master.key ]")
#         upload! 'config/master.key', "#{shared_path}/config/master.key"
#       end
#     end
#   end
# end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'Upload to shared/config'
  task :upload do
    on roles (:app) do
     upload! "config/master.key",  "#{shared_path}/config/master.key"
     upload! "config/puma_prod.rb",  "#{shared_path}/config/puma.rb"
     upload! "config/nginx_prod.conf",  "#{shared_path}/config/nginx.conf"
    end
  end


  desc "reload the database with seed data"
  task :seed do
    puts "Seeding db with seed file located at db/seeds.rb"
    run "cd #{current_path}; bin/rails db:seed RAILS_ENV=production"
  end


  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  # after  :finishing,    :restart
  # after "deploy:updated", "newrelic:notice_deployment"
end

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
set :linked_files, %w{config/puma.rb config/nginx.conf config/master.key}

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
                    #'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'
set :linked_dirs, fetch(:linked_dirs, []).push('public/packs', 'node_modules')