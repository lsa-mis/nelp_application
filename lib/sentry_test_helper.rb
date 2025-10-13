# frozen_string_literal: true

# Helper module for testing Sentry configuration in production
# Usage in Rails console:
#   require './lib/sentry_test_helper'
#   SentryTestHelper.verify_config
#   SentryTestHelper.test_message
#   SentryTestHelper.test_exception
#   SentryTestHelper.test_with_sampling
#   SentryTestHelper.full_test
module SentryTestHelper
  class << self
    # Verify Sentry configuration without sending events
    def verify_config
      puts "\n=== Sentry Configuration ==="
      puts "Environment: #{Rails.env}"
      puts "Enabled environments: #{Sentry.configuration.enabled_environments.inspect}"
      puts "Is enabled: #{Sentry.configuration.enabled_environments.include?(Rails.env)}"
      puts "DSN configured: #{Sentry.configuration.dsn.present?}"
      puts "DSN (masked): #{mask_dsn(Sentry.configuration.dsn)}" if Sentry.configuration.dsn
      puts "Sample rate: #{Sentry.configuration.sample_rate}"
      puts "Traces sample rate: #{Sentry.configuration.traces_sample_rate}"
      puts "Release: #{Sentry.configuration.release}"
      puts "Environment: #{Sentry.configuration.environment}"
      puts "==========================\n"
    end

    # Send a test message that bypasses sampling by sending to a transaction
    # This increases the likelihood of delivery
    def test_message(message = "Test message from #{Rails.env} at #{Time.current}")
      puts "\n=== Testing Sentry Message ==="
      puts "Sending message: #{message}"

      # Temporarily override sample rate
      original_sample_rate = Sentry.configuration.sample_rate
      Sentry.configuration.sample_rate = 1.0

      begin
        event_id = Sentry.capture_message(message, level: :info)
        puts "Event ID: #{event_id}"
        puts "Status: #{event_id ? 'Sent successfully!' : 'Failed to send (returned nil)'}"
        puts "Note: Check Sentry dashboard in a few moments"
      ensure
        # Restore original sample rate
        Sentry.configuration.sample_rate = original_sample_rate
      end

      puts "===========================\n"
      event_id
    end

    # Send a test exception that bypasses sampling
    def test_exception
      puts "\n=== Testing Sentry Exception ==="

      # Temporarily override sample rate
      original_sample_rate = Sentry.configuration.sample_rate
      Sentry.configuration.sample_rate = 1.0

      begin
        begin
          raise StandardError, "Test exception from #{Rails.env} at #{Time.current}"
        rescue StandardError => e
          event_id = Sentry.capture_exception(e)
          puts "Exception raised and captured"
          puts "Event ID: #{event_id}"
          puts "Status: #{event_id ? 'Sent successfully!' : 'Failed to send (returned nil)'}"
          puts "Note: Check Sentry dashboard in a few moments"
          event_id
        end
      ensure
        # Restore original sample rate
        Sentry.configuration.sample_rate = original_sample_rate
      end

      puts "=============================\n"
    end

    # Send multiple messages to test sampling (some should get through)
    def test_with_sampling(count = 20)
      puts "\n=== Testing with Normal Sampling ==="
      puts "Sending #{count} messages with #{(Sentry.configuration.sample_rate * 100).to_i}% sample rate"
      puts "Expected to see approximately #{(count * Sentry.configuration.sample_rate).round} events"

      sent_ids = []
      count.times do |i|
        event_id = Sentry.capture_message("Sampled test message #{i + 1}/#{count} at #{Time.current}")
        sent_ids << event_id if event_id
        print "."
      end

      puts "\n"
      puts "Event IDs returned: #{sent_ids.count}/#{count}"
      puts "Note: Check Sentry dashboard in a few moments"
      puts "==================================\n"
      sent_ids
    end

    # Full diagnostic test
    def full_test
      verify_config
      sleep 1
      test_message
      sleep 1
      test_exception
      puts "\n✅ Testing complete! Check your Sentry dashboard."
    end

    private

    def mask_dsn(dsn)
      return 'Not configured' if dsn.blank?

      # Mask the secret part of the DSN
      # DSN format: https://public_key@sentry.io/project_id
      dsn.to_s.gsub(/(?<=https:\/\/)([^@]+)(?=@)/) { |match| "*" * match.length }
    rescue StandardError
      'Error masking DSN'
    end
  end
end
