# Enhance assets:precompile to build CSS first
# This ensures compatibility with deployment systems like Hatchbox that call assets:precompile directly

# Override dartsass:build to use our css:build task instead
# This ensures ActiveAdmin styles are properly compiled
if Rake::Task.task_defined?("dartsass:build")
  Rake::Task["dartsass:build"].clear

  namespace :dartsass do
    desc "Build CSS with custom css:build task"
    task :build => :environment do
      # Run our custom css:build task that includes ActiveAdmin styles
      Rake::Task["css:build"].invoke if Rake::Task.task_defined?("css:build")
    end
  end
end

# Also enhance assets:precompile directly with css:build as a fallback
Rake::Task["assets:precompile"].enhance(["css:build"]) if Rake::Task.task_defined?("css:build")

# Disable SCSS processing in Sprockets to prevent sassc dependency errors
# This is necessary because we're using dartsass-rails instead of sassc-rails
namespace :assets do
  task :environment do
    if defined?(Sprockets) && Rails.application.assets
      # Remove SCSS processors that require sassc
      ['text/scss', 'text/sass'].each do |content_type|
        Rails.application.assets.unregister_processor(content_type, Sprockets::SasscProcessor) if defined?(Sprockets::SasscProcessor)
        Rails.application.assets.unregister_processor(content_type, Sprockets::ScssProcessor) if defined?(Sprockets::ScssProcessor)
        Rails.application.assets.unregister_processor(content_type, Sprockets::SassProcessor) if defined?(Sprockets::SassProcessor)
      end
    end
  end
end
