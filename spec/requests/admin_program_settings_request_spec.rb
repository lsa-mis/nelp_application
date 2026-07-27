# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::ProgramSettings', type: :request do
  let(:admin_user) { create(:admin_user) }

  before { sign_in admin_user }

  it 'requires authentication' do
    sign_out admin_user
    get admin_program_settings_path
    expect(response).to redirect_to(new_admin_user_session_path)
  end

  it 'lists and creates program settings' do
    get admin_program_settings_path
    expect(response).to have_http_status(:success)

    expect do
      post admin_program_settings_path, params: {
        program_setting: {
          program_year: 2099,
          application_fee: 100,
          program_fee: 400,
          active: false,
          allow_payments: true,
          program_open: 1.day.ago,
          program_close: 1.month.from_now,
          open_instructions: 'Open',
          close_instructions: 'Closed',
          payment_instructions: 'Pay'
        }
      }
    end.to change(ProgramSetting, :count).by(1)

    expect(response).to redirect_to(admin_program_setting_path(ProgramSetting.last))
  end
end
