require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NelpApplication
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2
    config.dartsass.builds = {
      "application.scss" => "application.css",
      "active_admin.scss" => "active_admin.css"
    }
    config.dartsass.build_options << " --load-path=#{Gem.loaded_specs['activeadmin'].full_gem_path}/app/assets/stylesheets"
    config.dartsass.source_dir = "app/scss"
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.active_storage.variant_processor = :mini_magick

    # Add trix to dartsass load paths
    if defined?(DartSass)
      config.dartsass.load_paths << Gem.loaded_specs['trix'].full_gem_path + "/app/assets/stylesheets"
      config.dartsass.builds = {
        "active_admin.scss" => "active_admin.css",
      }
    end
  end
end
