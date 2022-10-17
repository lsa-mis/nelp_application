class StaticPagesController < ApplicationController
  def home
    redirect_to all_payments_path if user_signed_in?
  end

  def about
    @about_message = StaticPage.find_by(location: 'about').message if StaticPage.find_by(location: 'about').present?
  end

  def privacy
    @privacy_message = StaticPage.find_by(location: 'privacy').message if StaticPage.find_by(location: 'privacy').present?
  end

  def terms
    @terms_message = StaticPage.find_by(location: 'terms').message if StaticPage.find_by(location: 'terms').present?
  end
end
