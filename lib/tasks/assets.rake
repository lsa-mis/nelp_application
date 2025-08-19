# Enhance assets:precompile to build CSS with dartsass first
# This ensures compatibility with deployment systems like Hatchbox that call assets:precompile directly

# Ensure dartsass:build runs before assets:precompile
Rake::Task["assets:precompile"].enhance(["dartsass:build"]) if Rake::Task.task_defined?("dartsass:build")

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
