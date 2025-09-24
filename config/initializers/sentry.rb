# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)

  # Release tracking with enhanced debugging
  hatchbox_commit = ENV['HATCHBOX_COMMIT']
  sentry_release = ENV['SENTRY_RELEASE']
  git_commit = `git rev-parse --short HEAD 2>/dev/null`.strip.presence

  # Debug logging to understand what values we have
  Rails.logger.info "=== Sentry Release Debug ==="
  Rails.logger.info "HATCHBOX_COMMIT: #{hatchbox_commit.inspect}"
  Rails.logger.info "SENTRY_RELEASE: #{sentry_release.inspect}"
  Rails.logger.info "Git commit: #{git_commit.inspect}"

  # Determine the best release value
  config.release = if hatchbox_commit.present? && hatchbox_commit != '${HATCHBOX_COMMIT}'
                     hatchbox_commit
                   elsif sentry_release.present? && sentry_release != '${HATCHBOX_COMMIT}'
                     sentry_release
                   elsif git_commit.present?
                     git_commit
                   else
                     'unknown'
                   end

  Rails.logger.info "Final Sentry Release: #{config.release}"
  Rails.logger.info "=== End Sentry Release Debug ==="

  config.enabled_environments = %w[production staging]
  config.environment = Rails.env.to_s

  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # Add data like request headers and IP for users
  config.send_default_pii = true

  # Enable sending logs to Sentry
  config.enable_logs = true
  config.enabled_patches = [:logger]

  # Performance monitoring
  config.enable_tracing = true
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
    event.tags[:controller] = event.request&.data&.dig(:controller)
    event.tags[:action] = event.request&.data&.dig(:action)
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
