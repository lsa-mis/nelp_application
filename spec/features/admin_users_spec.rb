require 'rails_helper'

RSpec.describe 'Admin::Users', type: :feature do
  let!(:admin_user) { create(:admin_user) }
  let!(:program_setting) do
    create(:program_setting, :active, program_year: Date.current.year, application_fee: 100, program_fee: 400)
  end
  let!(:user1) { create(:user, email: 'user1@example.com') }
  let!(:user2) { create(:user, email: 'user2@example.com') }

  before do
    # User1 has a nonzero balance, user2 will have zero balance
    create(:payment, user: user1, total_amount: '10000', transaction_status: '1', program_year: program_setting.program_year) # $100 paid, $500 due
    create(:payment, user: user2, total_amount: '50000', transaction_status: '1', program_year: program_setting.program_year) # $500 paid, $0 due

    visit new_admin_user_session_path
    fill_in 'Email', with: admin_user.email
    fill_in 'Password', with: admin_user.password
    click_button 'Login'
  end

  it 'shows the users index with correct columns and balances' do
    visit admin_users_path
    expect(page).to have_content('Users')
    expect(page).to have_content(user1.email)
    expect(page).to have_content(user2.email)
    expect(page).to have_content('Balance Due')
    expect(page).to have_content('Sign In Count')
    # Check balance formatting
    expect(page).to have_content('$400.00') # user1 owes $400 ($500 - $100 paid)
    expect(page).to have_content('$0.00')   # user2 owes $0
  end

  it 'filters users by email' do
    visit admin_users_path
    select user1.email, from: 'Email'
    click_button 'Filter'
    within('table') do
      expect(page).to have_content(user1.email)
      expect(page).not_to have_content(user2.email)
    end
  end

  it 'shows only zero balance users in the zero_balance scope' do
    visit admin_users_path(scope: 'zero_balance')
    within('table') do
      expect(page).to have_content(user2.email)
      expect(page).not_to have_content(user1.email)
    end
  end

  it 'redirects non-admin users from admin users page' do
    click_link 'Logout'
    visit admin_users_path
    expect(page).to have_content('You need to sign in or sign up before continuing')
  end
end
