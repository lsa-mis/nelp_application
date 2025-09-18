require 'rails_helper'

RSpec.describe 'Admin::Payments', type: :feature do
  let!(:admin_user) { FactoryBot.create(:admin_user) }
  let!(:user) { FactoryBot.create(:user) }
  let!(:payment) do
    FactoryBot.create(:payment, user: user, total_amount: '12345', transaction_type: '1', transaction_status: '1',
                                program_year: Date.current.year)
  end

  before do
    visit new_admin_user_session_path
    fill_in 'Email', with: admin_user.email
    fill_in 'Password', with: admin_user.password
    click_button 'Login'
  end

  describe 'index page' do
    it 'shows the correct columns and values' do
      visit admin_payments_path
      expect(page).to have_content(user.email)
      expect(page).to have_content('123.45') # Total Amount formatted
      expect(page).to have_content('1')      # Transaction Type
      expect(page).to have_content('1')      # Transaction Status
      expect(page).to have_content(Date.current.year)
    end

    it 'filters by user' do
      visit admin_payments_path
      select user.email, from: 'User'
      click_button 'Filter'
      expect(page).to have_content(user.email)
    end
  end

  describe 'show page' do
    it 'displays all payment attributes' do
      visit admin_payment_path(payment)
      expect(page).to have_content(payment.transaction_id)
      expect(page).to have_content(payment.total_amount)
      expect(page).to have_content(payment.transaction_type)
      expect(page).to have_content(payment.transaction_status)
      expect(page).to have_content(payment.program_year)
    end
  end

  describe 'new payment form' do
    it 'shows correct default values and creates a payment' do
      visit new_admin_payment_path
      expect(page).to have_field('Transaction type', with: '1')
      expect(page).to have_field('Transaction status', with: '1')
      expect(page).to have_field('Transaction date', with: DateTime.now.strftime('%Y%m%d%H%M'))
      fill_in 'Total amount', with: 5000
      select user.email, from: 'User'
      fill_in 'Transaction', with: 'TX123'
      fill_in 'Account type', with: 'Checking'
      fill_in 'Result message', with: 'Success'
      fill_in 'Program year', with: Date.current.year
      click_button 'Create Payment'
      expect(page).to have_content('Payment was successfully created').or have_content('Payment Details')
      expect(page).to have_content('5000')
    end
  end

  describe 'edit payment form' do
    it 'shows persisted values and updates payment' do
      visit edit_admin_payment_path(payment)
      expect(page).to have_field('Total amount', with: payment.total_amount)
      fill_in 'Total amount', with: 20_000
      click_button 'Update Payment'
      expect(page).to have_content('Payment was successfully updated').or have_content('Payment Details')
      expect(page).to have_content('20000')
    end
  end

  describe 'authorization' do
    it 'redirects non-admin users' do
      click_link 'Logout'
      visit admin_payments_path
      expect(page).to have_content('You need to sign in or sign up before continuing')
    end
  end
end
