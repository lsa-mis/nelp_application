require 'rails_helper'

RSpec.describe 'UserSessions', type: :request do
  describe 'POST /users/sign_in' do
    let(:password) { 'Password123!' }
    let!(:user) { create(:user, email: 'sanitize@example.com', password: password, password_confirmation: password) }

    it 'authenticates successfully when email contains a null byte' do
      post user_session_path, params: {
        user: {
          email: "sanitize@example.com\u0000",
          password: password,
        },
      }

      expect(response).to redirect_to(root_path)
      expect(request.env['warden'].user).to eq(user)
    end

    it 'authenticates with extra nested params containing null bytes' do
      post user_session_path, params: {
        user: {
          email: "sanitize@example.com\u0000",
          password: password,
          metadata: {
            token: "abc\u0000123",
            flags: ["a\u0000", "b"],
          },
        },
      }

      expect(response).to redirect_to(root_path)
      expect(request.env['warden'].user).to eq(user)
    end

    it 'authenticates when nested metadata includes non-string values' do
      post user_session_path, params: {
        user: {
          email: "sanitize@example.com\u0000",
          password: password,
          metadata: {
            attempts: 2,
            token: "xyz\u0000",
          },
        },
      }

      expect(response).to redirect_to(root_path)
      expect(request.env['warden'].user).to eq(user)
    end

    it 'does not raise when user params are missing' do
      expect do
        post user_session_path, params: {}
      end.not_to raise_error

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Log in')
    end
  end
end
