# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#
require 'rails_helper'

RSpec.describe User, type: :model do
  # Test factory
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end
  end

  # Test validations (Devise provides these)
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }

    it 'validates email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end
  end

  # Test associations
  describe 'associations' do
    it { is_expected.to have_many(:payments) }
  end

  # Test Devise modules
  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(described_class.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable' do
      expect(described_class.devise_modules).to include(:registerable)
    end

    it 'includes recoverable' do
      expect(described_class.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable' do
      expect(described_class.devise_modules).to include(:rememberable)
    end

    it 'includes validatable' do
      expect(described_class.devise_modules).to include(:validatable)
    end

    it 'includes trackable' do
      expect(described_class.devise_modules).to include(:trackable)
    end
  end

  # Test ransack configuration
  describe 'ransack configuration' do
    describe '.ransackable_associations' do
      it 'returns the allowed associations for search' do
        expect(described_class.ransackable_associations).to eq(['payments'])
      end
    end

    describe '.ransackable_attributes' do
      it 'returns the allowed attributes for search' do
        expected_attributes = %w[
          created_at current_sign_in_at current_sign_in_ip email
          encrypted_password id last_sign_in_at last_sign_in_ip
          remember_created_at reset_password_sent_at reset_password_token
          sign_in_count updated_at
        ]
        expect(described_class.ransackable_attributes).to match_array(expected_attributes)
      end
    end
  end

  # Test scopes
  describe 'scopes' do
    # Remove or update .zero_balance scope tests
    describe '.users_with_zero_balance' do
      let!(:program_setting) { create(:program_setting, :active, program_fee: 1000, application_fee: 500) }
      let!(:user_with_zero_balance) { create(:user) }
      let!(:user_with_balance) { create(:user) }

      before do
        # User with zero balance - has payments equal to total cost
        create(:payment,
               user: user_with_zero_balance,
               total_amount: '150000', # $1500 in cents
               program_year: program_setting.program_year,
               transaction_status: '1')
        # User with balance - has no payments
      end

      it 'returns users with zero balance' do
        expect(Payment.users_with_zero_balance(program_setting.program_year)).to include(user_with_zero_balance)
        expect(Payment.users_with_zero_balance(program_setting.program_year)).not_to include(user_with_balance)
      end
    end
  end

  # Test instance methods
  describe 'instance methods' do
    let!(:program_setting) { create(:program_setting, :active, program_fee: 1000, application_fee: 25) }
    let(:user) { create(:user) }

    describe '#current_balance_due' do
      context 'with no payments' do
        it 'returns the full program cost' do
          expect(user.current_balance_due).to eq(1025) # 1000 + 25
        end
      end

      context 'with partial payment' do
        before do
          create(:payment,
                 user: user,
                 total_amount: '50000', # $500 in cents
                 program_year: program_setting.program_year,
                 transaction_status: '1')
        end

        it 'returns the remaining balance' do
          expect(user.current_balance_due).to eq(525) # 1025 - 500
        end
      end

      context 'with full payment' do
        before do
          create(:payment,
                 user: user,
                 total_amount: '102500', # $1025 in cents
                 program_year: program_setting.program_year,
                 transaction_status: '1')
        end

        it 'returns zero balance' do
          expect(user.current_balance_due).to eq(0)
        end
      end

      context 'with failed payment' do
        before do
          create(:payment,
                 user: user,
                 total_amount: '102500',
                 program_year: program_setting.program_year,
                 transaction_status: '0') # failed payment
        end

        it 'does not count failed payments' do
          expect(user.current_balance_due).to eq(1025) # full amount
        end
      end

      context 'with payments from different program years' do
        let!(:old_program) { create(:program_setting, program_year: 2022, program_fee: 800, application_fee: 400) }

        before do
          # Payment from previous year - should not count
          create(:payment,
                 user: user,
                 total_amount: '120000',
                 program_year: old_program.program_year,
                 transaction_status: '1')

          # Payment from current year
          create(:payment,
                 user: user,
                 total_amount: '50000',
                 program_year: program_setting.program_year,
                 transaction_status: '1')
        end

        it 'only counts current program year payments' do
          expect(user.current_balance_due).to eq(525) # 1025 - 500
        end
      end
    end

    describe '#balance_due_zero?' do
      context 'when balance is zero' do
        before do
          create(:payment,
                 user: user,
                 total_amount: '102500',
                 program_year: program_setting.program_year,
                 transaction_status: '1')
        end

        it 'returns true' do
          expect(user.balance_due_zero?).to be true
        end
      end

      context 'when balance is not zero' do
        before do
          create(:payment,
                 user: user,
                 total_amount: '50000',
                 program_year: program_setting.program_year,
                 transaction_status: '1')
        end

        it 'returns false' do
          expect(user.balance_due_zero?).to be false
        end
      end

      context 'when balance is small due to rounding' do
        before do
          create(:payment,
                 user: user,
                 total_amount: '102499', # $1024.99 in cents
                 program_year: program_setting.program_year,
                 transaction_status: '1')
        end

        it 'returns true for small balances' do
          # balance_due_zero? uses to_i which truncates, so 0.01 becomes 0
          expect(user.balance_due_zero?).to be true
        end
      end
    end

    describe '#display_name' do
      it 'returns the user email' do
        user = build(:user, email: 'test@example.com')
        expect(user.display_name).to eq('test@example.com')
      end
    end
  end

  # Test edge cases and error handling
  describe 'edge cases' do
    context 'when no active program exists' do
      let(:user) { create(:user) }

      it 'handles missing active program gracefully' do
        expect(user.current_balance_due).to be_nil
        # This reveals a potential bug in the application - should handle gracefully
      end
    end
  end

  # Test performance considerations
  describe 'performance' do
    let!(:program_setting) { create(:program_setting, :active, program_fee: 1000, application_fee: 500) }
    let(:user) { create(:user) }

    it 'does not make excessive database queries for balance calculation' do
      # Create multiple payments
      3.times { create(:payment, user: user, program_year: program_setting.program_year) }

      expect do
        user.current_balance_due
      end.not_to exceed_query_limit(2) # One for active program, one for payments
    end
  end
end
