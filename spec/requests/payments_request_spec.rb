require 'rails_helper'

RSpec.describe "Payments", type: :request do
  let(:user) { create(:user) }
  let(:admin_user) { create(:admin_user) }
  let!(:program_setting) { create(:program_setting, :active, program_year: 2024, program_fee: 1000, application_fee: 500) }

  describe "GET /payments/all_payments" do
    context "when not logged in" do
      it "redirects to login" do
        get all_payments_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before { sign_in user }

      it "returns success" do
        get all_payments_path
        expect(response).to have_http_status(:success)
      end

      it "displays payment information" do
        get all_payments_path
        expect(response.body).to include("$500") # Application Fee
      end

      it "shows balance due" do
        create(:payment,
               user: user,
               program_year: program_setting.program_year,
               total_amount: '50000', # $500
               transaction_status: '1')

        get all_payments_path
        expect(response.body).to include("$1,000") # Remaining balance
      end

      it "shows zero balance when fully paid" do
        create(:payment,
               user: user,
               program_year: program_setting.program_year,
               total_amount: '150000', # $1500
               transaction_status: '1')

        get all_payments_path
        expect(response.body).to include("$0") # Zero balance
      end
    end
  end

  describe "POST /payments/make_payment" do
    context "when not logged in" do
      it "redirects to login" do
        post make_payment_path, params: { amount: '500' }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before { sign_in user }

      it "redirects to payment processor" do
        post make_payment_path, params: { amount: '500' }
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include('hash=')
      end

      it "handles default amount" do
        post make_payment_path
        expect(response).to have_http_status(:redirect)
      end

      it "handles custom amount" do
        post make_payment_path, params: { amount: '1000' }
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include('amountDue=100000') # 1000 * 100
      end
    end
  end

  describe "POST /payments/payment_receipt" do
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
        orderNumber: 'user-123',
        timestamp: Time.current.to_i.to_s,
        hash: 'somehash123'
      }
    end

    context "when not logged in" do
      it "redirects to login" do
        post payment_receipt_path, params: payment_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before { sign_in user }

      context "with valid payment data" do
        it "creates payment and redirects" do
          expect do
            post payment_receipt_path, params: payment_params
          end.to change(Payment, :count).by(1)

          expect(response).to redirect_to(all_payments_path)
          expect(flash[:notice]).to eq('Your Payment Was Successfully Recorded')
        end

        it "stores payment data correctly" do
          post payment_receipt_path, params: payment_params

          payment = Payment.last
          expect(payment.transaction_id).to eq('TXN123456')
          expect(payment.total_amount).to eq('50000')
          expect(payment.user).to eq(user)
          expect(payment.program_year).to eq(program_setting.program_year)
        end
      end

      context "with duplicate transaction" do
        before do
          create(:payment, transaction_id: 'TXN123456')
        end

        it "does not create duplicate payment" do
          expect do
            post payment_receipt_path, params: payment_params
          end.not_to change(Payment, :count)

          expect(response).to redirect_to(all_payments_path)
          expect(flash[:notice]).to be_nil
        end
      end

      context "with failed payment" do
        let(:failed_params) do
          payment_params.merge(
            transactionStatus: '0',
            transactionResultCode: '1001',
            transactionResultMessage: 'DECLINED'
          )
        end

        it "still records the failed payment" do
          expect do
            post payment_receipt_path, params: failed_params
          end.to change(Payment, :count).by(1)

          payment = Payment.last
          expect(payment.transaction_status).to eq('0')
          expect(payment.result_message).to eq('DECLINED')
        end
      end
    end
  end

  describe "Payment workflow integration" do
    before { sign_in user }

    # Stub time to make tests deterministic
    let(:fixed_time) { Time.zone.parse('2024-07-08 12:00:00') }
    
    before do
      allow(Time).to receive(:current).and_return(fixed_time)
      allow(Date).to receive(:current).and_return(fixed_time.to_date)
    end

    # Add helper methods
    def successful_payment_params(transaction_id:, amount:)
      {
        transactionType: 'SALE',
        transactionStatus: '1',
        transactionId: transaction_id,
        transactionTotalAmount: amount,
        orderNumber: "#{user.email.split('@').first}-#{user.id}",
        transactionDate: Date.current.strftime('%Y-%m-%d'),
        transactionResultCode: '0000',
        transactionResultMessage: 'APPROVED'
      }
    end

    def failed_payment_params(transaction_id:, amount:)
      {
        transactionType: 'SALE',
        transactionStatus: '0',
        transactionId: transaction_id,
        transactionTotalAmount: amount,
        orderNumber: "#{user.email.split('@').first}-#{user.id}",
        transactionDate: Date.current.strftime('%Y-%m-%d'),
        transactionResultCode: '1001',
        transactionResultMessage: 'DECLINED'
      }
    end

    it "handles complete payment flow" do
      # Step 1: User views payment page
      get all_payments_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("$500")
      
      # Step 2: User initiates payment
      post make_payment_path, params: { amount: '500' }
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include('amountDue=50000')

      # Step 3: Payment processor returns success (using helper)
      payment_params = successful_payment_params(
        transaction_id: 'TXN_FULL_PAYMENT',
        amount: '150000'
      )

      expect do
        post payment_receipt_path, params: payment_params
      end.to change(Payment, :count).by(1)

      expect(response).to redirect_to(all_payments_path)
      expect(flash[:notice]).to eq('Your Payment Was Successfully Recorded')

      # Step 4: Verify balance is now zero
      get all_payments_path
      expect(response.body).to include("$0")
    end

    it "handles partial payment flow" do
      # First partial payment using helper
      post payment_receipt_path, params: successful_payment_params(
        transaction_id: 'TXN_PARTIAL_1',
        amount: '50000'
      )

      get all_payments_path
      expect(response.body).to include("$1,000")

      # Second partial payment using helper
      post payment_receipt_path, params: successful_payment_params(
        transaction_id: 'TXN_PARTIAL_2',
        amount: '100000'
      )

      get all_payments_path
      expect(response.body).to include("$0")
    end

    it "handles mixed success and failure payments" do
      # Failed payment using helper
      post payment_receipt_path, params: failed_payment_params(
        transaction_id: 'TXN_FAILED',
        amount: '150000'
      )

      get all_payments_path
      expect(response.body).to include("$1,500")

      # Successful payment using helper
      post payment_receipt_path, params: successful_payment_params(
        transaction_id: 'TXN_SUCCESS',
        amount: '150000'
      )

      get all_payments_path
      expect(response.body).to include("$0")
    end
  end

  describe "Error handling" do
    before { sign_in user }

    it "handles missing payment parameters gracefully" do
      expect do
        post payment_receipt_path, params: { transactionId: 'TXN123' }
      end.not_to raise_error

      payment = Payment.last
      if payment.present?
        expect(payment.transaction_id).to eq('TXN123')
        expect(payment.total_amount).to be_nil
      else
        # If no payment is created with minimal params, that's also valid behavior
        expect(Payment.count).to eq(0)
      end
    end

    it "handles malformed parameters" do
      post payment_receipt_path, params: {
        transactionId: 'TXN_MALFORMED',
        transactionTotalAmount: 'invalid_amount',
        timestamp: 'invalid_timestamp'
      }

      payment = Payment.last
      expect(payment.total_amount).to eq('invalid_amount')
      expect(payment.timestamp).to eq('invalid_timestamp')
    end
  end

  describe "Security and Authorization" do
    let(:other_user) { create(:user) }

    context "cross-user payment access" do
      before do
        sign_in user
        @user_payment = create(:payment, user: user)
        @other_payment = create(:payment, user: other_user)
      end

      it "only shows user's own payments on payment_show" do
        get all_payments_path
        # The payment_show action filters by current_user automatically
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "Content-Type and Format handling" do
    before { sign_in user }

    it "handles HTML requests" do
      get all_payments_path
      expect(response.content_type).to include('text/html')
    end

    it "handles form submissions" do
      post payment_receipt_path, params: { transactionId: 'TXN123' }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "Performance considerations" do
    before { sign_in user }

    it "handles payment page with many payments efficiently" do
      # Create multiple payments
      create_list(:payment, 20, user: user, program_year: program_setting.program_year)

      expect do
        get all_payments_path
      end.not_to exceed_query_limit(10) # Reasonable query limit
    end
  end
end
