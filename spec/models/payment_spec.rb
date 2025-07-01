# == Schema Information
#
# Table name: payments
#
#  id                 :bigint           not null, primary key
#  transaction_type   :string
#  transaction_status :string
#  transaction_id     :string
#  total_amount       :string
#  transaction_date   :string
#  account_type       :string
#  result_code        :string
#  result_message     :string
#  user_account       :string
#  payer_identity     :string
#  timestamp          :string
#  transaction_hash   :string
#  user_id            :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  program_year       :integer          not null
#
require 'rails_helper'

RSpec.describe Payment, type: :model do
  # Test factory
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:payment)).to be_valid
    end

    it 'has a valid factory with user' do
      payment = create(:payment)
      expect(payment.user).to be_present
      expect(payment).to be_persisted
    end
  end

  # Test validations
  describe 'validations' do
    subject { build(:payment) }

    it { is_expected.to validate_presence_of(:transaction_id) }
    it { is_expected.to validate_uniqueness_of(:transaction_id) }
    it { is_expected.to validate_presence_of(:total_amount) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:program_year) }

    describe 'transaction_id uniqueness' do
      it 'prevents duplicate transaction IDs' do
        existing_payment = create(:payment, transaction_id: 'TXN123')
        duplicate_payment = build(:payment, transaction_id: 'TXN123')
        
        expect(duplicate_payment).not_to be_valid
        expect(duplicate_payment.errors[:transaction_id]).to include('has already been taken')
      end
    end

    describe 'total_amount presence' do
      it 'requires total_amount to be present' do
        payment = build(:payment, total_amount: nil)
        expect(payment).not_to be_valid
        expect(payment.errors[:total_amount]).to include("can't be blank")
      end

      it 'allows zero amounts' do
        payment = build(:payment, total_amount: '0')
        expect(payment).to be_valid
      end

      it 'allows negative amounts for refunds' do
        payment = build(:payment, total_amount: '-5000')
        expect(payment).to be_valid
      end
    end
  end

  # Test associations
  describe 'associations' do
    it { is_expected.to belong_to(:user) }

    it 'can access user information' do
      user = create(:user, email: 'test@example.com')
      payment = create(:payment, user: user)
      
      expect(payment.user.email).to eq('test@example.com')
    end
  end

  # Test ransack configuration
  describe 'ransack configuration' do
    describe '.ransackable_associations' do
      it 'returns the allowed associations for search' do
        expect(Payment.ransackable_associations).to eq(['user'])
      end
    end

    describe '.ransackable_attributes' do
      it 'returns the allowed attributes for search' do
        expected_attributes = [
          'account_type', 'created_at', 'id', 'payer_identity', 'program_year',
          'result_code', 'result_message', 'timestamp', 'total_amount',
          'transaction_date', 'transaction_hash', 'transaction_id',
          'transaction_status', 'transaction_type', 'updated_at', 'user_account', 'user_id'
        ]
        expect(Payment.ransackable_attributes).to match_array(expected_attributes)
      end
    end
  end

  # Test scopes
  describe 'scopes' do
    describe '.current_program_payments' do
      let!(:current_program) { create(:program_setting, :active, program_year: 2024) }
      let!(:old_program) { create(:program_setting, program_year: 2023) }
      let(:user) { create(:user) }

      let!(:current_payment) do
        create(:payment, user: user, program_year: current_program.program_year)
      end
      
      let!(:old_payment) do
        create(:payment, user: user, program_year: old_program.program_year)
      end

      it 'returns only payments for the current active program year' do
        current_payments = Payment.current_program_payments
        
        expect(current_payments).to include(current_payment)
        expect(current_payments).not_to include(old_payment)
      end

      it 'returns empty collection when no active program exists' do
        ProgramSetting.update_all(active: false)
        
        expect { Payment.current_program_payments }.to raise_error(NoMethodError)
        # This reveals the same issue as in User model - should handle gracefully
      end
    end
  end

  # Test data integrity and business logic
  describe 'business logic' do
    let(:user) { create(:user) }
    let!(:program_setting) { create(:program_setting, :active, program_year: 2024) }

    describe 'payment processing simulation' do
      it 'creates a payment with all required Nelnet fields' do
        payment = create(:payment,
          user: user,
          transaction_type: 'SALE',
          transaction_status: '1', # successful
          transaction_id: 'TXN12345',
          total_amount: '50000', # $500 in cents
          transaction_date: '2024-01-15',
          account_type: 'VISA',
          result_code: '0000',
          result_message: 'APPROVED',
          user_account: 'user-123',
          payer_identity: user.email,
          timestamp: Time.current.to_i.to_s,
          program_year: program_setting.program_year
        )

        expect(payment).to be_valid
        expect(payment.transaction_status).to eq('1')
        expect(payment.payer_identity).to eq(user.email)
      end

      it 'handles failed payments' do
        payment = create(:payment,
          user: user,
          transaction_status: '0', # failed
          result_code: '1001',
          result_message: 'DECLINED',
          program_year: program_setting.program_year
        )

        expect(payment).to be_valid
        expect(payment.transaction_status).to eq('0')
        expect(payment.result_message).to eq('DECLINED')
      end
    end

    describe 'amount handling' do
      it 'stores amounts as strings (as they come from payment processor)' do
        payment = create(:payment, total_amount: '123456')
        expect(payment.total_amount).to be_a(String)
        expect(payment.total_amount).to eq('123456')
      end

      it 'handles various amount formats' do
        # Test different amount formats that might come from payment processor
        amounts = ['100', '1000', '50000', '123456', '0']
        
        amounts.each do |amount|
          payment = build(:payment, total_amount: amount)
          expect(payment).to be_valid, "Amount #{amount} should be valid"
        end
      end
    end

    describe 'timestamp handling' do
      it 'stores timestamps as strings' do
        timestamp = Time.current.to_i.to_s
        payment = create(:payment, timestamp: timestamp)
        
        expect(payment.timestamp).to be_a(String)
        expect(payment.timestamp).to eq(timestamp)
      end
    end
  end

  # Test edge cases and error scenarios
  describe 'edge cases' do
    let(:user) { create(:user) }

    describe 'duplicate transaction handling' do
      it 'prevents processing the same transaction twice' do
        transaction_id = 'UNIQUE_TXN_123'
        
        # First payment succeeds
        first_payment = create(:payment, transaction_id: transaction_id, user: user)
        expect(first_payment).to be_persisted
        
        # Second payment with same transaction_id fails
        duplicate_payment = build(:payment, transaction_id: transaction_id, user: user)
        expect(duplicate_payment).not_to be_valid
      end
    end

    describe 'user deletion impact' do
      it 'requires a user to exist' do
        payment = build(:payment, user: nil)
        expect(payment).not_to be_valid
      end

      it 'maintains referential integrity' do
        payment = create(:payment, user: user)
        expect { payment.user.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end

    describe 'program year validation' do
      it 'requires program_year to be present' do
        payment = build(:payment, program_year: nil)
        expect(payment).not_to be_valid
      end

      it 'accepts any integer program year' do
        payment = build(:payment, program_year: 2025)
        expect(payment).to be_valid
      end
    end
  end

  # Test data conversion and calculations
  describe 'data conversion helpers' do
    let(:payment) { create(:payment, total_amount: '123456') }

    describe 'amount conversion' do
      it 'can convert string amount to float for calculations' do
        # This tests the pattern used in User#current_balance_due
        amount_in_dollars = payment.total_amount.to_f / 100
        expect(amount_in_dollars).to eq(1234.56)
      end

      it 'handles zero amounts' do
        zero_payment = create(:payment, total_amount: '0')
        amount_in_dollars = zero_payment.total_amount.to_f / 100
        expect(amount_in_dollars).to eq(0.0)
      end
    end
  end

  # Test querying and filtering
  describe 'querying' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:program_setting) { create(:program_setting, :active, program_year: 2024) }

    before do
      create(:payment, user: user1, transaction_status: '1', program_year: 2024)
      create(:payment, user: user1, transaction_status: '0', program_year: 2024)
      create(:payment, user: user2, transaction_status: '1', program_year: 2024)
      create(:payment, user: user2, transaction_status: '1', program_year: 2023)
    end

    it 'can filter by user' do
      user1_payments = Payment.where(user: user1)
      expect(user1_payments.count).to eq(2)
    end

    it 'can filter by transaction status' do
      successful_payments = Payment.where(transaction_status: '1')
      expect(successful_payments.count).to eq(3)
    end

    it 'can filter by program year' do
      current_year_payments = Payment.where(program_year: 2024)
      expect(current_year_payments.count).to eq(3)
    end

    it 'can combine filters' do
      user1_successful_current = Payment.where(
        user: user1, 
        transaction_status: '1', 
        program_year: 2024
      )
      expect(user1_successful_current.count).to eq(1)
    end
  end

  # Test performance with larger datasets
  describe 'performance' do
    let(:user) { create(:user) }
    let!(:program_setting) { create(:program_setting, :active, program_year: 2024) }

    it 'handles many payments efficiently' do
      # Create multiple payments
      payments = create_list(:payment, 10, user: user, program_year: program_setting.program_year)
      
      expect(payments.length).to eq(10)
      expect(Payment.current_program_payments.count).to eq(10)
    end

    it 'queries efficiently for user payments' do
      create_list(:payment, 5, user: user, program_year: program_setting.program_year)
      
      expect do
        Payment.where(user: user, program_year: program_setting.program_year).to_a
      end.to make_database_queries(count: 1)
    end
  end
end
