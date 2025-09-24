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
end
