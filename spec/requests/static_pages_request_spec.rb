require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  describe 'GET /terms with malformed headers' do
    it 'responds successfully when HTTP_USER_AGENT contains invalid bytes' do
      malformed_user_agent = "12345'\"\\');|]*%00{%0d%0a<%00>\xBF\x27".b

      get terms_path, headers: { 'HTTP_USER_AGENT' => malformed_user_agent }

      expect(response).to have_http_status(:success)
    end
  end
end
