require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
  # This assumes you have a factory for User and are using Devise for authentication.
  # You might need to include Devise test helpers in your rails_helper.rb:
  # config.include Devise::Test::ControllerHelpers, type: :controller

  let(:user) { FactoryBot.create(:user) } # Using FactoryBot to create a user

  describe 'GET #home' do
    context 'when user is not signed in' do
      it 'returns a successful response' do
        get :home
        expect(response).to be_successful
      end

      it 'assigns @home_message if static page for home exists' do
        StaticPage.create(location: 'home', message: 'Welcome!')
        get :home
        expect(assigns(:home_message).to_s).to include('Welcome!')
      end

      it 'does not assign @home_message if static page for home does not exist' do
        get :home
        expect(assigns(:home_message)).to be_nil
      end
    end

    context 'when user is signed in' do
      before do
        sign_in user
      end

      it 'redirects to all_payments_path' do
        get :home
        expect(response).to redirect_to(all_payments_path)
      end
    end
  end

  describe 'GET #about' do
    it 'returns a successful response' do
      get :about
      expect(response).to be_successful
    end

    it 'assigns @about_message if static page for about exists' do
      StaticPage.create(location: 'about', message: 'About us page')
      get :about
      expect(assigns(:about_message).to_s).to include('About us page')
    end

    it 'does not assign @about_message if static page for about does not exist' do
      get :about
      expect(assigns(:about_message)).to be_nil
    end
  end

  describe 'GET #privacy' do
    it 'returns a successful response' do
      get :privacy
      expect(response).to be_successful
    end

    it 'assigns @privacy_message if static page for privacy exists' do
      StaticPage.create(location: 'privacy', message: 'Privacy policy')
      get :privacy
      expect(assigns(:privacy_message).to_s).to include('Privacy policy')
    end

    it 'does not assign @privacy_message if static page for privacy does not exist' do
      get :privacy
      expect(assigns(:privacy_message)).to be_nil
    end
  end

  describe 'GET #terms' do
    it 'returns a successful response' do
      get :terms
      expect(response).to be_successful
    end

    it 'assigns @terms_message if static page for terms exists' do
      StaticPage.create(location: 'terms', message: 'Terms and conditions')
      get :terms
      expect(assigns(:terms_message).to_s).to include('Terms and conditions')
    end

    it 'does not assign @terms_message if static page for terms does not exist' do
      get :terms
      expect(assigns(:terms_message)).to be_nil
    end
  end
end
