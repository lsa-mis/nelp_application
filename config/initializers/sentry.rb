# frozen_string_literal: true

Sentry.init do |config|
  # Get Sentry DSN from credentials
  sentry_credentials = Rails.application.credentials.sentry
  config.dsn = if sentry_credentials.is_a?(Hash)
                 sentry_credentials[:dsn]
               else
                 sentry_credentials
               end

  # Release tracking - check multiple sources for commit hash
  revision = ENV['REVISION']
  hatchbox_commit = ENV['HATCHBOX_COMMIT']
  sentry_release = ENV['SENTRY_RELEASE']
  git_commit = `git rev-parse --short HEAD 2>/dev/null`.strip.presence

  # Check for other possible Hatchbox environment variables
  other_env_vars = {
    'HATCHBOX_REVISION' => ENV['HATCHBOX_REVISION'],
    'GIT_COMMIT' => ENV['GIT_COMMIT'],
    'COMMIT_SHA' => ENV['COMMIT_SHA'],
    'DEPLOY_REVISION' => ENV['DEPLOY_REVISION'],
    'RELEASE' => ENV['RELEASE']
  }

  # Try to extract commit from deployment path
  deployment_path_commit = nil
  if Rails.root.to_s.include?('/releases/')
    # Extract from path like /home/deploy/nelp-staging/releases/20250924180023/
    path_parts = Rails.root.to_s.split('/')
    if path_parts.include?('releases')
      release_index = path_parts.index('releases')
      if release_index && path_parts[release_index + 1]
        deployment_path_commit = path_parts[release_index + 1]
      end
    end
  end

  # Debug logging to understand what values we have
  Rails.logger.info "=== Sentry Release Debug ==="
  Rails.logger.info "REVISION: #{revision.inspect}"
  Rails.logger.info "HATCHBOX_COMMIT: #{hatchbox_commit.inspect}"
  Rails.logger.info "SENTRY_RELEASE: #{sentry_release.inspect}"
  Rails.logger.info "Git commit: #{git_commit.inspect}"
  Rails.logger.info "Deployment path commit: #{deployment_path_commit.inspect}"
  Rails.logger.info "Other env vars: #{other_env_vars.select { |k, v| v.present? }}"

  # Also log to a file for easier debugging
  begin
    File.open(Rails.root.join('log', 'sentry_debug.log'), 'a') do |f|
      f.puts "#{Time.current} - Sentry Release Debug:"
      f.puts "  REVISION: #{revision.inspect}"
      f.puts "  HATCHBOX_COMMIT: #{hatchbox_commit.inspect}"
      f.puts "  SENTRY_RELEASE: #{sentry_release.inspect}"
      f.puts "  Git commit: #{git_commit.inspect}"
      f.puts "  Deployment path commit: #{deployment_path_commit.inspect}"
      f.puts "  Other env vars: #{other_env_vars.select { |k, v| v.present? }}"
      f.puts "  Rails.root: #{Rails.root}"
    end
  rescue => e
    Rails.logger.error "Failed to write to sentry_debug.log: #{e.message}"
  end

  # Determine the best release value
  config.release = if revision.present?
                     revision
                   elsif hatchbox_commit.present? && hatchbox_commit != '${HATCHBOX_COMMIT}'
                     hatchbox_commit
                   elsif sentry_release.present? && sentry_release != '${HATCHBOX_COMMIT}'
                     sentry_release
                   elsif other_env_vars.values.any?(&:present?)
                     other_env_vars.values.find(&:present?)
                   elsif deployment_path_commit.present?
                     deployment_path_commit
                   elsif git_commit.present?
                     git_commit
                   else
                     'unknown'
                   end

  Rails.logger.info "Final Sentry Release: #{config.release}"
  Rails.logger.info "=== End Sentry Release Debug ==="

  # Send a test event to create the release in Sentry (only in staging/production)
  if Rails.env.staging? || Rails.env.production?
    begin
      Sentry.capture_message("Release #{config.release} deployed", level: :info)
      Rails.logger.info "Sent test message to Sentry for release: #{config.release}"
    rescue => e
      Rails.logger.error "Failed to send test message to Sentry: #{e.message}"
    end
  end

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
