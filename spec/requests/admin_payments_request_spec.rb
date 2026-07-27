# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Payments', type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }

  before { sign_in admin_user }

  it 'filters payments by user_id' do
    matching = create(:payment, user: user, program_year: Date.current.year)
    other_user = create(:user)
    create(:payment, user: other_user, program_year: Date.current.year)

    get admin_payments_path, params: { user_id: user.id }

    expect(response).to have_http_status(:success)
    expect(response.body).to include(matching.transaction_id)
    expect(response.body).to include(user.email)
  end

  it 'creates a payment with defaults' do
    expect do
      post admin_payments_path, params: {
        payment: {
          user_id: user.id,
          total_amount: '5000',
          transaction_type: '1',
          transaction_status: '1',
          transaction_id: "TX-#{SecureRandom.hex(4)}",
          transaction_date: Time.current.strftime('%Y%m%d%H%M'),
          account_type: 'Checking',
          result_message: 'Success',
          program_year: Date.current.year
        }
      }
    end.to change(Payment, :count).by(1)

    expect(response).to redirect_to(admin_payment_path(Payment.last))
  end
end
