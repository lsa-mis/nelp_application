# frozen_string_literal: true

module Admin
  class DashboardPaymentsQuery
    Result = Struct.new(
      :active_program,
      :user_rows,
      :recent_payments,
      :paid_in_full_count,
      :outstanding_count,
      :sort_column,
      :sort_order,
      keyword_init: true
    )

    def initialize(params:)
      @params = params
    end

    def call
      active_program = ProgramSetting.active_program.last
      return empty_result unless active_program

      sort_column = %w[user total_paid balance_due].include?(@params[:sort_column]) ? @params[:sort_column] : 'total_paid'
      sort_order = @params[:sort_order] == 'asc' ? 'asc' : 'desc'

      user_data = build_user_data(active_program)
      user_data = sort_user_data(user_data, sort_column, sort_order)

      paid_in_full_count = user_data.count { |row| row[:balance_due].to_i.zero? }
      outstanding_count = user_data.size - paid_in_full_count

      recent_payments = Payment.current_program_payments(active_program.program_year)
                               .includes(:user)
                               .order(created_at: :desc)
                               .limit(20)

      Result.new(
        active_program: active_program,
        user_rows: user_data,
        recent_payments: recent_payments,
        paid_in_full_count: paid_in_full_count,
        outstanding_count: outstanding_count,
        sort_column: sort_column,
        sort_order: sort_order
      )
    end

    private

    def empty_result
      Result.new(
        active_program: nil,
        user_rows: [],
        recent_payments: [],
        paid_in_full_count: 0,
        outstanding_count: 0,
        sort_column: 'total_paid',
        sort_order: 'desc'
      )
    end

    def build_user_data(active_program)
      user_totals = Payment.current_program_payments(active_program.program_year)
                           .where(transaction_status: '1')
                           .joins(:user)
                           .group('users.id', 'users.email')
                           .sum('payments.total_amount::float / 100')

      user_totals.map do |(user_id, user_email), total_paid|
        user = User.find(user_id)
        {
          user_id: user_id,
          user_email: user_email,
          user: user,
          total_paid: total_paid,
          balance_due: Payment.current_balance_due_for_user(user, active_program.program_year)
        }
      end
    end

    def sort_user_data(user_data, sort_column, sort_order)
      sorted = case sort_column
               when 'user'
                 user_data.sort_by { |data| data[:user_email].to_s.downcase }
               when 'balance_due'
                 user_data.sort_by { |data| data[:balance_due].to_f }
               else
                 user_data.sort_by { |data| data[:total_paid].to_f }
               end

      sort_order == 'desc' ? sorted.reverse : sorted
    end
  end
end
