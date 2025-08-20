# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)

  config.enabled_environments = %w[production staging]

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true

  # Enable sending logs to Sentry
  config.enable_logs = true
  # Patch Ruby logger to forward logs
  config.enabled_patches = [:logger]

  config.profiles_sample_rate = Rails.env.production? ? 0.1 : 1.0
  config.traces_sampler = lambda do |context|
    # Don't sample health check endpoints
    if context[:transaction_context][:name]&.include?('health_check')
      0.0
    else
      # Sample based on environment
      Rails.env.production? ? 0.1 : 1.0
    end
  end

  # Add additional context to errors
  config.before_send = lambda do |event, hint|
    # You can add custom data here
    if defined?(Current) && Current.user
      event.user = {
        id: Current.user.id,
        email: Current.user.email
      }
    end
    event
  end

  # Configure backtrace cleanup
  config.backtrace_cleanup_callback = lambda do |backtrace|
    Rails.backtrace_cleaner.clean(backtrace)
  end
end
