# frozen_string_literal: true

Sentry.init do |config|
  # Get Sentry DSN from credentials
  sentry_credentials = Rails.application.credentials.sentry
  config.dsn = if sentry_credentials.is_a?(Hash)
                 sentry_credentials[:dsn]
               else
                 sentry_credentials
               end

  # Release tracking using Hatchbox's HATCHBOX_REVISION environment variable
  config.release = ENV['HATCHBOX_REVISION'] ||
                   ENV['REVISION'] ||
                   ENV['HATCHBOX_COMMIT'] ||
                   `git rev-parse --short HEAD 2>/dev/null`.strip.presence ||
                   'unknown'

  config.enabled_environments = %w[production staging]
  config.environment = Rails.env.to_s

  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # Add data like request headers and IP for users
  config.send_default_pii = true

  # Enable sending logs to Sentry
  config.enable_logs = true
  config.enabled_patches = [:logger]

  # Performance monitoring
  config.traces_sample_rate = Rails.env.production? ? 0.1 : 1.0
  config.profiles_sample_rate = Rails.env.production? ? 0.1 : 1.0

  # Error sampling
  config.sample_rate = Rails.env.production? ? 0.1 : 1.0

  # Traces sampler with better filtering
  config.traces_sampler = lambda do |context|
    transaction_name = context[:transaction_context][:name]

    # Don't sample health checks and monitoring endpoints
    if transaction_name&.include?('health_check') ||
       transaction_name&.include?('/ping') ||
       transaction_name&.include?('/monitoring')
      0.0
    else
      Rails.env.production? ? 0.1 : 1.0
    end
  end

  # Enhanced before_send with filtering and context
  config.before_send = lambda do |event, _hint|
    # Skip health checks and other noise
    return nil if event.request&.url&.include?('health_check')
    return nil if event.request&.url&.include?('/ping')

    # Add user context
    if defined?(Current) && Current.user
      event.user = {
        id: Current.user.id,
        email: Current.user.email,
      }
    end

    # Add additional context
    event.tags ||= {}
    if event.request&.data.is_a?(Hash)
      event.tags[:controller] = event.request.data[:controller]
      event.tags[:action] = event.request.data[:action]
    end
    event.tags[:environment] = Rails.env.to_s

    # Remove sensitive headers
    if event.request&.headers
      sensitive_headers = %w[Authorization Cookie X-CSRF-Token]
      sensitive_headers.each do |header|
        event.request.headers.delete(header)
      end
    end

    event
  end

  # Configure backtrace cleanup
  config.backtrace_cleanup_callback = lambda do |backtrace|
    Rails.backtrace_cleaner.clean(backtrace)
  end
end
