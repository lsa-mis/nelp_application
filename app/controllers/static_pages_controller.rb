class StaticPagesController < ApplicationController
  def home
    redirect_to all_payments_path if user_signed_in?
    @home_message = StaticPage.find_by(location: 'home').message if StaticPage.find_by(location: 'home').present?
  end

  def about
    @about_message = StaticPage.find_by(location: 'about').message if StaticPage.find_by(location: 'about').present?
  end

  def privacy
    return if StaticPage.find_by(location: 'privacy').blank?

    @privacy_message = StaticPage.find_by(location: 'privacy').message
  end

  def terms
    @terms_message = StaticPage.find_by(location: 'terms').message if StaticPage.find_by(location: 'terms').present?
  end

  # Test endpoint for Sentry release tracking (remove after testing)
  def test_sentry
    if Rails.env.development? || Rails.env.staging?
      Sentry.capture_message("Test message from #{Rails.env} - Release: #{ENV['REVISION'] || 'unknown'}", level: :info)
      render json: {
        message: "Test message sent to Sentry",
        release: ENV['REVISION'] || 'unknown',
        environment: Rails.env
      }
    else
      render json: { error: "Not available in production" }, status: :forbidden
    end
  end
end
