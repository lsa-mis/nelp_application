# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accessible heading structure', type: :request do
  describe 'GET /' do
    it 'has a single h1 and no skipped heading levels' do
      create(:program_setting, :active)

      get root_path

      expect(response).to have_http_status(:success)
      main = main_from(response.body)
      assert_single_h1!(main, text: 'NELP Payment Portal')
      assert_heading_levels_do_not_skip!(main)
    end

    it 'demotes Action Text CMS h1s so the page keeps a single h1' do
      create(:program_setting, :active)
      create(
        :static_page,
        location: 'home',
        message: '<div><h1 class="cms-title">CMS Welcome</h1><p>Body copy</p></div>'
      )

      get root_path

      expect(response).to have_http_status(:success)
      main = main_from(response.body)
      assert_single_h1!(main, text: 'NELP Payment Portal')
      expect(main.css('h2').map { |n| n.text.strip }).to include('CMS Welcome')
      expect(main.at_css('h2.cms-title')).to be_present
      assert_heading_levels_do_not_skip!(main)
    end
  end

  describe 'Devise auth pages' do
    it 'uses a single Log in h1 on /users/sign_in' do
      get new_user_session_path

      expect(response).to have_http_status(:success)
      main = main_from(response.body)
      assert_single_h1!(main, text: 'Log in')
      assert_heading_levels_do_not_skip!(main)
    end

    it 'uses a single Sign up h1 on /users/sign_up' do
      get new_user_registration_path

      expect(response).to have_http_status(:success)
      main = main_from(response.body)
      assert_single_h1!(main, text: 'Sign up')
      assert_heading_levels_do_not_skip!(main)
    end
  end

  describe 'GET /payments/all_payments' do
    let(:user) { create(:user) }
    let!(:program_setting) do
      create(:program_setting, :active, program_year: 2024, program_fee: 1000, application_fee: 500)
    end

    before { sign_in user }

    context 'when the user has no payments' do
      it 'uses unpaid payment heading outline' do
        get all_payments_path

        expect(response).to have_http_status(:success)
        main = main_from(response.body)
        assert_single_h1!(main, text: 'Please pay your $500.00 application fee.')
        expect(main.at_css('h2')&.text&.strip).to eq('Pay by Credit Card (Visa, Mastercard, Discover, AMEX)')
        assert_heading_levels_do_not_skip!(main)
      end
    end

    context 'when the user has a successful payment' do
      before do
        create(
          :payment,
          user: user,
          program_year: program_setting.program_year,
          total_amount: '50000',
          transaction_status: '1',
          transaction_id: 'TXN-HEADING-1'
        )
      end

      it 'uses paid receipt heading outline with nested h2/h3' do
        get all_payments_path

        expect(response).to have_http_status(:success)
        main = main_from(response.body)
        assert_single_h1!(main, text: 'Your Payment Receipts')

        h2_texts = main.css('h2').map { |n| n.text.strip }
        expect(h2_texts).to include('Account Summary')
        expect(h2_texts).to include('Your transactions:')
        expect(main.css('h3').map { |n| n.text.strip }).to include('Transaction ID: TXN-HEADING-1')
        assert_heading_levels_do_not_skip!(main)
      end
    end
  end
end
