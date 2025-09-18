# Override assets:precompile to build CSS with dartsass first
# This ensures ActiveAdmin styles are compiled on Hatchbox deployments

require 'rake/task'

# We need to hook in after all tasks are loaded
# This is done by creating a new task that depends on the original
namespace :assets do
  # Create a new task that runs our CSS build
  desc 'Build CSS including ActiveAdmin styles'
  task build_css: :environment do
    puts '==> Building CSS with dartsass (including ActiveAdmin styles)...'
    active_admin_path = "#{Gem::Specification.find_by_name('activeadmin').gem_dir}/app/assets/stylesheets"
    sass_command = "sass app/assets/stylesheets:app/assets/builds --style=compressed --load-path=#{active_admin_path}"
    puts "    Command: #{sass_command}"

    raise 'CSS build failed!' unless system(sass_command)

    puts '    ✓ CSS build complete'
  end

  # Hook into the precompile task
  # This approach works by making build_css a prerequisite
  task precompile: :build_css

  # Disable SCSS processing in Sprockets to prevent sassc dependency errors
  task environment: :environment do
    if defined?(Sprockets) && Rails.application.assets
      # Remove SCSS processors that require sassc
      ['text/scss', 'text/sass'].each do |content_type|
        if defined?(Sprockets::SasscProcessor)
          Rails.application.assets.unregister_processor(content_type, Sprockets::SasscProcessor)
        end
        if defined?(Sprockets::ScssProcessor)
          Rails.application.assets.unregister_processor(content_type, Sprockets::ScssProcessor)
        end
        if defined?(Sprockets::SassProcessor)
          Rails.application.assets.unregister_processor(content_type, Sprockets::SassProcessor)
        end
      end
    end
  end
end

# Also make build_css a dependency of assets:clean to ensure proper cleanup
namespace :assets do
  task clean: :build_css do
    # Clean built CSS files
    FileUtils.rm_rf Rails.root.glob('app/assets/builds/*.css')
    FileUtils.rm_rf Rails.root.glob('app/assets/builds/*.css.map')
  end
end
