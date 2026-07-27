# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin resources', type: :request do
  let(:admin_user) { create(:admin_user, email: 'coverage-admin@example.com') }

  before { sign_in admin_user }

  describe 'Admin::Users' do
    let!(:user) { create(:user) }

    it 'lists and shows users' do
      get admin_users_path
      expect(response).to have_http_status(:success)

      get admin_users_path, params: { scope: 'zero_balance' }
      expect(response).to have_http_status(:success)

      get admin_user_path(user)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(user.email)
    end
  end

  describe 'Admin::AdminUsers' do
    it 'supports CRUD' do
      get admin_admin_users_path
      expect(response).to have_http_status(:success)

      get new_admin_admin_user_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Password confirmation')

      expect do
        post admin_admin_users_path, params: {
          admin_user: {
            email: 'new-admin@example.com',
            password: 'password',
            password_confirmation: 'password'
          }
        }
      end.to change(AdminUser, :count).by(1)

      created = AdminUser.find_by!(email: 'new-admin@example.com')
      get admin_admin_user_path(created)
      expect(response).to have_http_status(:success)

      get edit_admin_admin_user_path(created)
      expect(response).to have_http_status(:success)

      patch admin_admin_user_path(created), params: {
        admin_user: { email: 'updated-admin@example.com', password: '', password_confirmation: '' }
      }
      expect(response).to redirect_to(admin_admin_user_path(created))
      expect(created.reload.email).to eq('updated-admin@example.com')

      expect do
        delete admin_admin_user_path(created)
      end.to change(AdminUser, :count).by(-1)
    end
  end

  describe 'Admin::ProgramSettings' do
    let!(:setting) do
      create(:program_setting, program_year: 2088, active: false, application_fee: 50, program_fee: 150)
    end

    it 'supports show edit update destroy' do
      get admin_program_setting_path(setting)
      expect(response).to have_http_status(:success)

      get edit_admin_program_setting_path(setting)
      expect(response).to have_http_status(:success)

      patch admin_program_setting_path(setting), params: {
        program_setting: { application_fee: 75 }
      }
      expect(response).to redirect_to(admin_program_setting_path(setting))
      expect(setting.reload.application_fee).to eq(75)

      expect do
        delete admin_program_setting_path(setting)
      end.to change(ProgramSetting, :count).by(-1)
    end
  end

  describe 'Admin::StaticPages' do
    let!(:static_page) { create(:static_page, location: 'about') }

    it 'updates a static page' do
      patch admin_static_page_path(static_page), params: {
        static_page: { location: 'about', message: '<p>Updated</p>' }
      }
      expect(response).to redirect_to(admin_static_pages_path)
    end
  end

  describe 'Admin::Payments' do
    let(:user) { create(:user) }
    let!(:payment) { create(:payment, user: user, program_year: Date.current.year) }

    it 'renders edit and updates' do
      get edit_admin_payment_path(payment)
      expect(response).to have_http_status(:success)

      patch admin_payment_path(payment), params: {
        payment: { total_amount: '9999' }
      }
      expect(response).to redirect_to(admin_payment_path(payment))
      expect(payment.reload.total_amount).to eq('9999')
    end

    it 'renders new form' do
      get new_admin_payment_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Transaction type')
    end

    it 're-renders new on validation failure' do
      post admin_payments_path, params: {
        payment: {
          user_id: user.id,
          total_amount: '',
          transaction_id: '',
          program_year: Date.current.year
        }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 're-renders edit on validation failure' do
      patch admin_payment_path(payment), params: {
        payment: { total_amount: '' }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'filters by created_at range' do
      get admin_payments_path, params: {
        created_at_from: 1.day.ago.to_date.to_s,
        created_at_to: Date.current.to_s
      }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Admin::ProgramSettings invalid' do
    it 're-renders new and edit on validation failure' do
      post admin_program_settings_path, params: {
        program_setting: { program_year: nil, application_fee: 1, program_fee: 1 }
      }
      expect(response).to have_http_status(:unprocessable_content)

      setting = create(:program_setting, program_year: 2077, active: false)
      patch admin_program_setting_path(setting), params: {
        program_setting: { program_year: nil }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'renders new form' do
      get new_admin_program_setting_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Admin::AdminUsers invalid' do
    it 're-renders new and edit on validation failure' do
      post admin_admin_users_path, params: {
        admin_user: { email: '', password: 'password', password_confirmation: 'password' }
      }
      expect(response).to have_http_status(:unprocessable_content)

      other = create(:admin_user, email: 'other-admin@example.com')
      patch admin_admin_user_path(other), params: {
        admin_user: { email: '', password: 'password', password_confirmation: 'password' }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'Admin::StaticPages invalid' do
    it 're-renders edit on validation failure' do
      static_page = create(:static_page, location: 'home')
      patch admin_static_page_path(static_page), params: {
        static_page: { location: '' }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'AdminUsers::Passwords' do
    it 'renders forgot password form' do
      sign_out admin_user
      get new_admin_user_password_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Forgot your password')
    end
  end

  describe 'Admin::DashboardPaymentsQuery' do
    it 'sorts by user and balance_due' do
      program = create(:program_setting, :active, program_year: 2090, program_fee: 100, application_fee: 50)
      users = create_list(:user, 2)
      users.each_with_index do |user, idx|
        create(:payment, user: user, program_year: program.program_year, total_amount: (10_000 * (idx + 1)).to_s,
                         transaction_status: '1')
      end

      result = Admin::DashboardPaymentsQuery.new(params: { sort_column: 'user', sort_order: 'asc' }).call
      expect(result.user_rows.map { |r| r[:user_email] }).to eq(result.user_rows.map { |r| r[:user_email] }.sort)

      result = Admin::DashboardPaymentsQuery.new(params: { sort_column: 'balance_due', sort_order: 'desc' }).call
      balances = result.user_rows.map { |r| r[:balance_due].to_f }
      expect(balances).to eq(balances.sort.reverse)
    end
  end
end
