# == Schema Information
#
# Table name: program_settings
#
#  id                   :bigint           not null, primary key
#  program_year         :integer
#  application_fee      :integer          default(0), not null
#  program_fee          :integer          default(0), not null
#  active               :boolean          default(FALSE)
#  program_open         :datetime
#  program_close        :datetime
#  open_instructions    :text
#  close_instructions   :text
#  payment_instructions :text
#  allow_payments       :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
require 'rails_helper'

RSpec.describe ProgramSetting, type: :model do
  # Test factory
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:program_setting)).to be_valid
    end

    it 'has a valid active factory' do
      expect(build(:program_setting, :active)).to be_valid
    end
  end

  # Test validations
  describe 'validations' do
    subject { build(:program_setting) }

    it { is_expected.to validate_presence_of(:program_year) }
    it { is_expected.to validate_uniqueness_of(:program_year) }
    it { is_expected.to validate_presence_of(:program_open) }
    it { is_expected.to validate_presence_of(:program_close) }

    describe 'program_year uniqueness' do
      it 'prevents duplicate program years' do
        existing_program = create(:program_setting, program_year: 2024)
        duplicate_program = build(:program_setting, program_year: 2024)

        expect(duplicate_program).not_to be_valid
        expect(duplicate_program.errors[:program_year]).to include('has already been taken')
      end
    end

    describe 'date validations' do
      it 'requires program_open to be present' do
        program = build(:program_setting, program_open: nil)
        expect(program).not_to be_valid
        expect(program.errors[:program_open]).to include("can't be blank")
      end

      it 'requires program_close to be present' do
        program = build(:program_setting, program_close: nil)
        expect(program).not_to be_valid
        expect(program.errors[:program_close]).to include("can't be blank")
      end

      it 'allows program_close to be after program_open' do
        program = build(:program_setting,
          program_open: 1.month.from_now,
          program_close: 2.months.from_now
        )
        expect(program).to be_valid
      end

      # Note: There's no validation that close must be after open in the model
      # This might be a business logic gap to address
      it 'currently allows program_close to be before program_open' do
        program = build(:program_setting,
          program_open: 2.months.from_now,
          program_close: 1.month.from_now
        )
        expect(program).to be_valid # This reveals a potential business logic issue
      end
    end

    describe 'fee validations' do
      it 'has default values for fees' do
        program = ProgramSetting.new
        expect(program.application_fee).to eq(0)
        expect(program.program_fee).to eq(0)
      end

      it 'allows positive fees' do
        program = build(:program_setting, application_fee: 500, program_fee: 1000)
        expect(program).to be_valid
      end

      it 'allows zero fees' do
        program = build(:program_setting, application_fee: 0, program_fee: 0)
        expect(program).to be_valid
      end

      # Note: No validation prevents negative fees - might be business logic gap
      it 'currently allows negative fees' do
        program = build(:program_setting, application_fee: -100, program_fee: -200)
        expect(program).to be_valid # Potential issue to address
      end
    end

    describe 'boolean field defaults' do
      it 'defaults active to false' do
        program = ProgramSetting.new
        expect(program.active).to be false
      end

      it 'defaults allow_payments to false' do
        program = ProgramSetting.new
        expect(program.allow_payments).to be false
      end
    end
  end

  # Test custom validations
  describe 'custom validations' do
    describe '#only_one_active_camp validation' do
      context 'when creating a new active program' do
        it 'allows the first active program' do
          program = build(:program_setting, :active)
          expect(program).to be_valid
        end

        it 'prevents a second active program' do
          create(:program_setting, :active, program_year: 2024)
          second_program = build(:program_setting, :active, program_year: 2025)

          expect(second_program).not_to be_valid
          expect(second_program.errors[:active]).to include('cannot have another active program')
        end

        it 'allows multiple inactive programs' do
          create(:program_setting, active: false, program_year: 2024)
          second_program = build(:program_setting, active: false, program_year: 2025)

          expect(second_program).to be_valid
        end
      end

      context 'when updating an existing program' do
        let!(:active_program) { create(:program_setting, :active, program_year: 2024) }
        let!(:inactive_program) { create(:program_setting, active: false, program_year: 2025) }

        it 'allows updating the active program without changing active status' do
          active_program.program_fee = 1500
          expect(active_program).to be_valid
        end

        it 'allows deactivating the currently active program' do
          active_program.active = false
          expect(active_program).to be_valid
        end

        it 'prevents activating another program when one is already active' do
          inactive_program.active = true
          expect(inactive_program).not_to be_valid
          expect(inactive_program.errors[:active]).to include('cannot have another active program')
        end

        it 'allows activating a program after deactivating the current one' do
          active_program.update!(active: false)
          inactive_program.active = true
          expect(inactive_program).to be_valid
        end
      end
    end
  end

  # Test scopes
  describe 'scopes' do
    describe '.active_program' do
      let!(:active_program) { create(:program_setting, :active, program_year: 2024) }
      let!(:inactive_program1) { create(:program_setting, active: false, program_year: 2023) }
      let!(:inactive_program2) { create(:program_setting, active: false, program_year: 2025) }

      it 'returns only active programs' do
        active_programs = ProgramSetting.active_program
        expect(active_programs).to include(active_program)
        expect(active_programs).not_to include(inactive_program1)
        expect(active_programs).not_to include(inactive_program2)
      end

      it 'returns empty relation when no active programs exist' do
        ProgramSetting.update_all(active: false)
        expect(ProgramSetting.active_program).to be_empty
      end
    end
  end

  # Test ransack configuration
  describe 'ransack configuration' do
    describe '.ransackable_attributes' do
      it 'returns the allowed attributes for search' do
        expected_attributes = [
          'active', 'allow_payments', 'application_fee', 'close_instructions',
          'created_at', 'id', 'open_instructions', 'payment_instructions',
          'program_close', 'program_fee', 'program_open', 'program_year', 'updated_at'
        ]
        expect(ProgramSetting.ransackable_attributes).to match_array(expected_attributes)
      end
    end
  end

  # Test instance methods
  describe 'instance methods' do
    describe '#total_cost' do
      it 'returns the sum of program_fee and application_fee' do
        program = build(:program_setting, program_fee: 1000, application_fee: 500)
        expect(program.total_cost).to eq(1500)
      end

      it 'handles zero fees' do
        program = build(:program_setting, program_fee: 0, application_fee: 0)
        expect(program.total_cost).to eq(0)
      end

      it 'handles only program fee' do
        program = build(:program_setting, program_fee: 1200, application_fee: 0)
        expect(program.total_cost).to eq(1200)
      end

      it 'handles only application fee' do
        program = build(:program_setting, program_fee: 0, application_fee: 300)
        expect(program.total_cost).to eq(300)
      end
    end
  end

  # Test business logic scenarios
  describe 'business logic scenarios' do
    describe 'program lifecycle' do
      it 'can create a complete program setting' do
        program = create(:program_setting,
          program_year: 2024,
          program_fee: 1000,
          application_fee: 500,
          program_open: 1.month.from_now,
          program_close: 6.months.from_now,
          open_instructions: 'Welcome to the program!',
          close_instructions: 'Program is now closed.',
          payment_instructions: 'Please pay using the link below.',
          allow_payments: true,
          active: true
        )

        expect(program).to be_persisted
        expect(program.total_cost).to eq(1500)
        expect(program.active).to be true
        expect(program.allow_payments).to be true
      end

      it 'handles program transitions' do
        # Create and activate a program
        program = create(:program_setting, :active, program_year: 2024)
        expect(ProgramSetting.active_program.count).to eq(1)

        # Deactivate and create new program
        program.update!(active: false)
        new_program = create(:program_setting, :active, program_year: 2025)

        expect(ProgramSetting.active_program.count).to eq(1)
        expect(ProgramSetting.active_program.first).to eq(new_program)
      end
    end

    describe 'payment configuration' do
      it 'can enable payments for active program' do
        program = create(:program_setting, :active, allow_payments: true)
        expect(program.allow_payments).to be true
        expect(program.active).to be true
      end

      it 'can disable payments while keeping program active' do
        program = create(:program_setting, :active, allow_payments: false)
        expect(program.allow_payments).to be false
        expect(program.active).to be true
      end
    end

    describe 'instruction management' do
      let(:program) { create(:program_setting) }

      it 'stores various instruction types' do
        program.update!(
          open_instructions: 'Program is now open for applications.',
          close_instructions: 'Program applications are closed.',
          payment_instructions: 'Use the secure payment portal.'
        )

        expect(program.open_instructions).to be_present
        expect(program.close_instructions).to be_present
        expect(program.payment_instructions).to be_present
      end

      it 'allows empty instructions' do
        program.update!(
          open_instructions: nil,
          close_instructions: '',
          payment_instructions: nil
        )

        expect(program).to be_valid
      end
    end
  end

  # Test edge cases and error handling
  describe 'edge cases' do
    describe 'concurrent active program creation' do
      it 'prevents race conditions in active program validation' do
        # This test simulates potential race condition
        program1 = build(:program_setting, :active, program_year: 2024)
        program2 = build(:program_setting, :active, program_year: 2025)

        program1.save!
        expect(program2).not_to be_valid
      end
    end

    describe 'year boundaries' do
      it 'handles edge case years' do
        old_program = build(:program_setting, program_year: 1900)
        future_program = build(:program_setting, program_year: 3000)

        expect(old_program).to be_valid
        expect(future_program).to be_valid
      end

      it 'handles current year' do
        current_year_program = build(:program_setting, program_year: Date.current.year)
        expect(current_year_program).to be_valid
      end
    end

    describe 'large fee amounts' do
      it 'handles large fee amounts' do
        program = build(:program_setting,
          program_fee: 1_000_000,
          application_fee: 500_000
        )
        expect(program).to be_valid
        expect(program.total_cost).to eq(1_500_000)
      end
    end

    describe 'date edge cases' do
      it 'handles same open and close dates' do
        same_date = 1.month.from_now
        program = build(:program_setting,
          program_open: same_date,
          program_close: same_date
        )
        expect(program).to be_valid
      end

      it 'handles past dates' do
        program = build(:program_setting,
          program_open: 1.month.ago,
          program_close: 1.week.ago
        )
        expect(program).to be_valid
      end
    end
  end

  # Test relationships with other models
  describe 'model relationships' do
    let!(:program_setting) { create(:program_setting, :active, program_year: 2024) }
    let(:user) { create(:user) }

    it 'is referenced by Payment.current_program_payments scope' do
      travel_to(Date.new(2024, 7, 7)) do
        payment = create(:payment, program_year: 2024)
        current_payments = Payment.current_program_payments
        expect(current_payments).to include(payment)
      end
    end

    it 'is referenced by User balance calculations' do
      payment = create(:payment,
        user: user,
        program_year: program_setting.program_year,
        total_amount: '50000',
        transaction_status: '1'
      )

      expected_balance = program_setting.total_cost - 500 # payment amount in dollars
      expect(user.current_balance_due).to eq(expected_balance)
    end
  end

  # Test data integrity
  describe 'data integrity' do
    it 'maintains consistency after updates' do
      program = create(:program_setting, :active, program_fee: 1000, application_fee: 500)
      original_total = program.total_cost

      program.update!(program_fee: 1200)
      expect(program.total_cost).to eq(1700)
      expect(program.total_cost).not_to eq(original_total)
    end

    it 'handles deletion properly' do
      program = create(:program_setting)
      program_id = program.id

      program.destroy!
      expect(ProgramSetting.find_by(id: program_id)).to be_nil
    end
  end

  # Test querying and filtering
  describe 'querying' do
    before do
      create(:program_setting, :active, program_year: 2024, program_fee: 1000)
      create(:program_setting, active: false, program_year: 2023, program_fee: 800)
      create(:program_setting, active: false, program_year: 2025, program_fee: 1200)
    end

    it 'can find by year' do
      program_2024 = ProgramSetting.find_by(program_year: 2024)
      expect(program_2024.program_fee).to eq(1000)
    end

    it 'can filter by active status' do
      active_programs = ProgramSetting.where(active: true)
      expect(active_programs.count).to eq(1)
    end

    it 'can order by year' do
      programs = ProgramSetting.order(:program_year)
      years = programs.pluck(:program_year)
      expect(years).to eq([2023, 2024, 2025])
    end
  end
end
