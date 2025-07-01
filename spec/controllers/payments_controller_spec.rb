require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin_user) { create(:admin_user) }
  let!(:program_setting) { create(:program_setting, :active, program_year: 2024, program_fee: 1000, application_fee: 500) }

  # Helper method to mock current_program
  before do
    allow(controller).to receive(:current_program).and_return(program_setting)
  end

  describe 'authentication and authorization' do
    describe 'before_action filters' do
      context 'when user is not logged in' do
        it 'redirects to login for index' do
          get :index
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'redirects to login for payment_show' do
          get :payment_show
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'redirects to login for make_payment' do
          post :make_payment, params: { amount: '500' }
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'when regular user is logged in' do
        before { sign_in user }

        it 'allows access to payment_show' do
          get :payment_show
          expect(response).to have_http_status(:success)
        end

        it 'allows access to make_payment' do
          post :make_payment, params: { amount: '500' }
          expect(response).to have_http_status(:redirect)
        end

        it 'denies access to index (admin only)' do
          get :index
          expect(response).to redirect_to(root_url)
        end

        it 'denies access to destroy (admin only)' do
          payment = create(:payment, user: user)
          delete :destroy, params: { id: payment.id }
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when admin user is logged in' do
        before { sign_in admin_user }

        it 'allows access to index' do
          get :index
          expect(response).to have_http_status(:success)
        end

        it 'allows access to destroy' do
          payment = create(:payment, user: user)
          delete :destroy, params: { id: payment.id }
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'GET #index' do
    before { sign_in admin_user }

    it 'assigns current program payments' do
      current_payment = create(:payment, user: user, program_year: program_setting.program_year)
      old_payment = create(:payment, user: user, program_year: 2023)

      get :index

      expect(assigns(:payments)).to include(current_payment)
      expect(assigns(:payments)).not_to include(old_payment)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    context 'when accessed by regular user' do
      before { sign_in user }

      it 'redirects to root' do
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET #payment_show' do
    before { sign_in user }

    it 'calculates total cost correctly' do
      get :payment_show
      expect(assigns(:total_cost)).to eq(1500) # 1000 + 500
    end

    it 'finds users current payments for the program' do
      payment1 = create(:payment, user: user, program_year: program_setting.program_year)
      payment2 = create(:payment, user: user, program_year: 2023) # different year
      other_user_payment = create(:payment, program_year: program_setting.program_year)

      get :payment_show

      expect(assigns(:users_current_payments)).to include(payment1)
      expect(assigns(:users_current_payments)).not_to include(payment2)
      expect(assigns(:users_current_payments)).not_to include(other_user_payment)
    end

    it 'calculates total paid amount correctly' do
      create(:payment, 
             user: user, 
             program_year: program_setting.program_year,
             total_amount: '50000', # $500
             transaction_status: '1')
      create(:payment, 
             user: user, 
             program_year: program_setting.program_year,
             total_amount: '30000', # $300
             transaction_status: '1')
      create(:payment, 
             user: user, 
             program_year: program_setting.program_year,
             total_amount: '20000', # $200 - but failed
             transaction_status: '0')

      get :payment_show

      expect(assigns(:ttl_paid)).to eq(800) # (500 + 300) only successful payments
    end

    it 'calculates balance due correctly' do
      create(:payment, 
             user: user, 
             program_year: program_setting.program_year,
             total_amount: '50000', # $500
             transaction_status: '1')

      get :payment_show

      expect(assigns(:balance_due)).to eq(1000) # 1500 - 500
    end

    it 'handles no payments scenario' do
      get :payment_show

      expect(assigns(:ttl_paid)).to eq(0)
      expect(assigns(:balance_due)).to eq(1500)
    end

    it 'renders the payment_show template' do
      get :payment_show
      expect(response).to render_template(:payment_show)
    end
  end

  describe 'POST #make_payment' do
    before { sign_in user }

    it 'generates payment URL and redirects' do
      post :make_payment, params: { amount: '500' }
      expect(response).to have_http_status(:redirect)
    end

    it 'uses the provided amount' do
      expect(controller).to receive(:generate_hash).with(user, '500').and_return('http://test-url.com')
      post :make_payment, params: { amount: '500' }
    end

    it 'defaults to application fee when no amount provided' do
      expect(controller).to receive(:generate_hash).with(user, program_setting.application_fee.to_i).and_return('http://test-url.com')
      post :make_payment
    end
  end

  describe 'POST #payment_receipt' do
    before { sign_in user }

    let(:payment_params) do
      {
        transactionType: 'SALE',
        transactionStatus: '1',
        transactionId: 'TXN123456',
        transactionTotalAmount: '50000',
        transactionDate: '2024-01-15',
        transactionAcountType: 'VISA',
        transactionResultCode: '0000',
        transactionResultMessage: 'APPROVED',
        orderNumber: 'user-test@example.com',
        timestamp: Time.current.to_i.to_s,
        hash: 'somehash123'
      }
    end

    context 'with new transaction' do
      it 'creates a new payment record' do
        expect do
          post :payment_receipt, params: payment_params
        end.to change(Payment, :count).by(1)
      end

      it 'sets payment attributes correctly' do
        post :payment_receipt, params: payment_params

        payment = Payment.last
        expect(payment.transaction_type).to eq('SALE')
        expect(payment.transaction_status).to eq('1')
        expect(payment.transaction_id).to eq('TXN123456')
        expect(payment.total_amount).to eq('50000')
        expect(payment.user_id).to eq(user.id)
        expect(payment.program_year).to eq(program_setting.program_year)
        expect(payment.payer_identity).to eq(user.email)
      end

      it 'redirects to all_payments_path with success notice' do
        post :payment_receipt, params: payment_params
        expect(response).to redirect_to(all_payments_path)
        expect(flash[:notice]).to eq('Your Payment Was Successfully Recorded')
      end
    end

    context 'with duplicate transaction' do
      before do
        create(:payment, transaction_id: 'TXN123456')
      end

      it 'does not create a new payment record' do
        expect do
          post :payment_receipt, params: payment_params
        end.not_to change(Payment, :count)
      end

      it 'redirects to all_payments_path without notice' do
        post :payment_receipt, params: payment_params
        expect(response).to redirect_to(all_payments_path)
        expect(flash[:notice]).to be_nil
      end
    end

    context 'with failed payment' do
      let(:failed_payment_params) do
        payment_params.merge(
          transactionStatus: '0',
          transactionResultCode: '1001',
          transactionResultMessage: 'DECLINED'
        )
      end

      it 'still creates the payment record' do
        expect do
          post :payment_receipt, params: failed_payment_params
        end.to change(Payment, :count).by(1)

        payment = Payment.last
        expect(payment.transaction_status).to eq('0')
        expect(payment.result_message).to eq('DECLINED')
      end
    end
  end

  describe 'private methods' do
    before { sign_in user }

    describe '#generate_hash' do
      let(:amount) { 500 }

      before do
        # Mock credentials
        allow(Rails.application.credentials).to receive(:[]).with(:NELNET_SERVICE).and_return({
          DEVELOPMENT_KEY: 'dev_key_123',
          DEVELOPMENT_URL: 'https://dev.example.com/pay',
          PRODUCTION_KEY: 'prod_key_456',
          PRODUCTION_URL: 'https://prod.example.com/pay',
          ORDERTYPE: 'SALE',
          SERVICE_SELECTOR: 'QA'
        })
      end

      context 'in development environment' do
        before do
          allow(Rails.env).to receive(:development?).and_return(true)
        end

        it 'uses development credentials' do
          result = controller.send(:generate_hash, user, amount)
          expect(result).to include('dev.example.com')
          expect(result).to include('hash=')
        end

        it 'includes correct payment parameters' do
          result = controller.send(:generate_hash, user, amount)
          expect(result).to include("amountDue=#{amount * 100}")
          expect(result).to include("orderType=SALE")
          expect(result).to include("orderDescription=NELP%20Application%20Fees")
        end

        it 'includes user account information' do
          result = controller.send(:generate_hash, user, amount)
          expected_account = "#{user.email.partition('@').first}-#{user.id}"
          expect(result).to include("orderNumber=#{expected_account}")
        end

        it 'includes SHA256 hash' do
          result = controller.send(:generate_hash, user, amount)
          expect(result).to match(/hash=[a-f0-9]{64}$/) # SHA256 produces 64-char hex string
        end
      end

      context 'in production environment' do
        before do
          allow(Rails.env).to receive(:development?).and_return(false)
          allow(Rails.application.credentials).to receive(:[]).with(:NELNET_SERVICE).and_return({
            DEVELOPMENT_KEY: 'dev_key_123',
            DEVELOPMENT_URL: 'https://dev.example.com/pay',
            PRODUCTION_KEY: 'prod_key_456',
            PRODUCTION_URL: 'https://prod.example.com/pay',
            ORDERTYPE: 'SALE',
            SERVICE_SELECTOR: 'PROD'
          })
        end

        it 'uses production credentials' do
          result = controller.send(:generate_hash, user, amount)
          expect(result).to include('prod.example.com')
        end
      end

      context 'with default amount' do
        it 'uses application fee as default' do
          result = controller.send(:generate_hash, user)
          expect(result).to include("amountDue=#{program_setting.application_fee * 100}")
        end
      end

      context 'with different amounts' do
        it 'handles zero amount' do
          result = controller.send(:generate_hash, user, 0)
          expect(result).to include("amountDue=0")
        end

        it 'handles large amounts' do
          result = controller.send(:generate_hash, user, 10000)
          expect(result).to include("amountDue=1000000") # 10000 * 100
        end
      end

      context 'hash generation consistency' do
        it 'generates the same hash for same parameters' do
          # Mock Time to ensure consistent timestamp
          time = Time.current
          allow(DateTime).to receive(:now).and_return(time)

          result1 = controller.send(:generate_hash, user, amount)
          result2 = controller.send(:generate_hash, user, amount)

          hash1 = result1.split('hash=').last
          hash2 = result2.split('hash=').last
          expect(hash1).to eq(hash2)
        end

        it 'generates different hashes for different amounts' do
          time = Time.current
          allow(DateTime).to receive(:now).and_return(time)

          result1 = controller.send(:generate_hash, user, 500)
          result2 = controller.send(:generate_hash, user, 600)

          hash1 = result1.split('hash=').last
          hash2 = result2.split('hash=').last
          expect(hash1).not_to eq(hash2)
        end
      end
    end

    describe '#url_params' do
      let(:all_params) do
        {
          amount: '500',
          transactionType: 'SALE',
          transactionStatus: '1',
          transactionId: 'TXN123',
          unwanted_param: 'should_be_filtered',
          authenticity_token: 'csrf_token'
        }
      end

      it 'permits only allowed parameters' do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new(all_params))
        
        permitted = controller.send(:url_params)
        expect(permitted.keys).to include('amount', 'transactionType', 'transactionStatus', 'transactionId')
        expect(permitted.keys).not_to include('unwanted_param', 'authenticity_token')
      end
    end
  end

  describe 'error handling and edge cases' do
    before { sign_in user }

    context 'when program setting is missing' do
      before do
        program_setting.destroy
        allow(controller).to receive(:current_program).and_return(nil)
      end

      it 'handles missing program gracefully in payment_show' do
        expect { get :payment_show }.to raise_error(NoMethodError)
        # This reveals the same error handling issue found in models
      end
    end

    context 'with invalid payment receipt parameters' do
      it 'handles missing required parameters' do
        expect do
          post :payment_receipt, params: { transactionId: 'TXN123' } # missing other required params
        end.not_to raise_error # Rails will use nil values
      end
    end

    context 'with malformed payment data' do
      let(:malformed_params) do
        {
          transactionId: 'TXN123',
          transactionTotalAmount: 'invalid_amount',
          timestamp: 'invalid_timestamp'
        }
      end

      it 'creates payment with malformed data' do
        expect do
          post :payment_receipt, params: malformed_params
        end.to change(Payment, :count).by(1)

        payment = Payment.last
        expect(payment.total_amount).to eq('invalid_amount') # Stored as-is
        expect(payment.timestamp).to eq('invalid_timestamp')
      end
    end
  end

  describe 'integration scenarios' do
    before { sign_in user }

    context 'complete payment workflow' do
      it 'handles full payment process' do
        # Step 1: User views payment page
        get :payment_show
        expect(assigns(:balance_due)).to eq(1500)

        # Step 2: User initiates payment
        post :make_payment, params: { amount: '1500' }
        expect(response).to have_http_status(:redirect)

        # Step 3: Payment processor returns successful payment
        payment_params = {
          transactionType: 'SALE',
          transactionStatus: '1',
          transactionId: 'TXN789',
          transactionTotalAmount: '150000', # $1500 in cents
          orderNumber: "#{user.email.split('@').first}-#{user.id}",
          timestamp: Time.current.to_i.to_s
        }

        expect do
          post :payment_receipt, params: payment_params
        end.to change(Payment, :count).by(1)

        # Step 4: Verify payment was recorded
        payment = Payment.last
        expect(payment.user).to eq(user)
        expect(payment.total_amount).to eq('150000')
        expect(payment.transaction_status).to eq('1')

        # Step 5: Check updated balance
        get :payment_show
        expect(assigns(:balance_due)).to eq(0)
      end
    end

    context 'partial payment scenario' do
      it 'handles multiple partial payments' do
        # First payment
        post :payment_receipt, params: {
          transactionId: 'TXN001',
          transactionTotalAmount: '50000', # $500
          transactionStatus: '1'
        }

        get :payment_show
        expect(assigns(:balance_due)).to eq(1000)

        # Second payment
        post :payment_receipt, params: {
          transactionId: 'TXN002',
          transactionTotalAmount: '100000', # $1000
          transactionStatus: '1'
        }

        get :payment_show
        expect(assigns(:balance_due)).to eq(0)
      end
    end
  end
end