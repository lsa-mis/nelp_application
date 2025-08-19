# Custom deployment tasks for Hatchbox
namespace :deploy do
  desc "Build CSS and precompile assets for deployment"
  task :assets => :environment do
    puts "Building CSS with dartsass..."
    Rake::Task['css:build'].invoke

    puts "Precompiling assets..."
    Rake::Task['assets:precompile'].invoke
  end
end
