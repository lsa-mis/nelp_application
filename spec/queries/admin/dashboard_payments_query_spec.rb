# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardPaymentsQuery do
  describe '#call' do
    it 'returns an empty result when there is no active program' do
      result = described_class.new(params: {}).call

      expect(result.active_program).to be_nil
      expect(result.user_rows).to eq([])
      expect(result.recent_payments).to eq([])
      expect(result.paid_in_full_count).to eq(0)
      expect(result.outstanding_count).to eq(0)
    end

    context 'with an active program and successful payments' do
      let!(:program) { create(:program_setting, :active, program_year: 2024, program_fee: 1000, application_fee: 500) }
      let!(:paid_user) { create(:user, email: 'paid@example.com') }
      let!(:partial_user) { create(:user, email: 'partial@example.com') }

      before do
        create(:payment, user: paid_user, program_year: 2024, total_amount: '150000', transaction_status: '1')
        create(:payment, user: partial_user, program_year: 2024, total_amount: '50000', transaction_status: '1')
        create(:payment, user: partial_user, program_year: 2024, total_amount: '99999', transaction_status: '0')
      end

      it 'aggregates successful payments and ignores failed ones' do
        result = described_class.new(params: {}).call
        rows_by_email = result.user_rows.index_by { |row| row[:user_email] }

        expect(rows_by_email['paid@example.com'][:total_paid]).to eq(1500.0)
        expect(rows_by_email['paid@example.com'][:balance_due]).to eq(0)
        expect(rows_by_email['partial@example.com'][:total_paid]).to eq(500.0)
        expect(rows_by_email['partial@example.com'][:balance_due]).to eq(1000)
      end

      it 'counts paid-in-full and outstanding users' do
        result = described_class.new(params: {}).call

        expect(result.paid_in_full_count).to eq(1)
        expect(result.outstanding_count).to eq(1)
      end

      it 'sorts by balance_due ascending when requested' do
        result = described_class.new(params: { sort_column: 'balance_due', sort_order: 'asc' }).call

        expect(result.user_rows.map { |row| row[:user_email] }).to eq(%w[paid@example.com partial@example.com])
        expect(result.sort_column).to eq('balance_due')
        expect(result.sort_order).to eq('asc')
      end

      it 'sorts by user email descending when requested' do
        result = described_class.new(params: { sort_column: 'user', sort_order: 'desc' }).call

        expect(result.user_rows.map { |row| row[:user_email] }).to eq(%w[partial@example.com paid@example.com])
      end

      it 'falls back to total_paid desc for invalid sort params' do
        result = described_class.new(params: { sort_column: 'hacked', sort_order: 'sideways' }).call

        expect(result.sort_column).to eq('total_paid')
        expect(result.sort_order).to eq('desc')
        expect(result.user_rows.map { |row| row[:user_email] }).to eq(%w[paid@example.com partial@example.com])
      end

      it 'limits recent payments to the active program year' do
        older = create(:payment, user: paid_user, program_year: 2023, total_amount: '1000', transaction_status: '1')
        recent = Payment.find_by!(user: paid_user, program_year: 2024, total_amount: '150000')

        result = described_class.new(params: {}).call

        expect(result.recent_payments).to include(recent)
        expect(result.recent_payments).not_to include(older)
      end
    end
  end
end
