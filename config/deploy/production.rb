set :rails_env, 'production'

before 'deploy:assets:precompile', 'deploy:yarn_install'

namespace :deploy do
  desc 'Run yarn install'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install")
      end
    end
  end
end