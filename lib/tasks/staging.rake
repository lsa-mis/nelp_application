# Staging-specific deployment tasks
namespace :staging do
  desc 'Build CSS and precompile assets for staging deployment'
  task deploy: :environment do
    puts 'Building CSS with dartsass...'
    Rake::Task['css:build'].invoke

    puts 'Precompiling assets...'
    Rake::Task['assets:precompile'].invoke
  end
end
