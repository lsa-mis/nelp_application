require 'rails_helper'

RSpec.describe 'Admin dashboard', type: :request do
  let(:admin_user) do
    create(:admin_user, email: 'admin-dashboard@example.com', password: 'password', password_confirmation: 'password')
  end

  before do
    sign_in admin_user
  end

  it 'renders dashboard when no active program exists' do
    get '/admin'

    expect(response).to have_http_status(:success)
    expect(response.body).to include('No active program found')
  end

  it 'renders payment sections when an active program exists' do
    program = create(:program_setting, :active, program_year: 2024, program_fee: 1000, application_fee: 500)
    user = create(:user, email: 'payer@example.com')
    create(:payment, user: user, program_year: program.program_year, total_amount: '50000', transaction_status: '1')

    get '/admin'

    expect(response).to have_http_status(:success)
    expect(response.body).to include('User Payment Totals - Program Year 2024')
    expect(response.body).to include('Recent Payments - Program Year 2024')
    expect(response.body).to include('payer@example.com')
  end

  it 'renders empty payment states for active program without payments' do
    create(:program_setting, :active, program_year: 2024, program_fee: 1000, application_fee: 500)

    get '/admin'

    expect(response).to have_http_status(:success)
    expect(response.body).to include('No successful payments found for the active program.')
    expect(response.body).to include('No payments found for the active program.')
  end

  it 'supports dashboard sorting and pagination paths' do
    program = create(:program_setting, :active, program_year: 2024, program_fee: 1000, application_fee: 500)
    create_list(:user, 21).each_with_index do |user, idx|
      create(:payment,
             user: user,
             program_year: program.program_year,
             total_amount: (50_000 + (idx * 1000)).to_s,
             transaction_status: '1')
    end

    get '/admin', params: { sort_column: 'user', sort_order: 'asc', page: 2 }
    expect(response).to have_http_status(:success)
    expect(response.body).to include('User Payment Totals - Program Year 2024')
    expect(response.body).to include('Previous')

    get '/admin', params: { sort_column: 'balance_due', sort_order: 'asc', page: 1 }
    expect(response).to have_http_status(:success)
    expect(response.body).to include('Next')
  end

  it 'renders admin users index and form' do
    get '/admin/admin_users'
    expect(response).to have_http_status(:success)

    get '/admin/admin_users/new'
    expect(response).to have_http_status(:success)
    expect(response.body).to include('Password confirmation')
  end

  it 'renders static pages index' do
    create(:static_page, location: 'terms')

    get '/admin/static_pages'

    expect(response).to have_http_status(:success)
    expect(response.body).to include('Manage messages on static pages')
  end

  it 'renders static page edit form with rich text input' do
    static_page = create(:static_page, location: 'privacy')

    get "/admin/static_pages/#{static_page.id}/edit"

    expect(response).to have_http_status(:success)
    expect(response.body).to include('trix')
  end
end
