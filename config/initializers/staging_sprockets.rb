# Disable SCSS processing in Sprockets for staging environment
if Rails.env.staging?
  # This runs before Sprockets tries to process any files
  Rails.application.config.before_initialize do
    if defined?(Sprockets)
      Rails.application.assets.configure do |env|
        # Remove any SCSS processors
        if defined?(Sprockets::SasscProcessor)
          env.unregister_processor('text/scss', Sprockets::SasscProcessor)
          env.unregister_processor('text/css', Sprockets::SasscProcessor)
        end

        if defined?(Sprockets::ScssProcessor)
          env.unregister_processor('text/scss', Sprockets::ScssProcessor)
        end
      end
    end
  end
end
