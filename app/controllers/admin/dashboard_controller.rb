# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def show
      result = Admin::DashboardPaymentsQuery.new(params: params).call
      @active_program = result.active_program
      @sort_column = result.sort_column
      @sort_order = result.sort_order
      @paid_in_full_count = result.paid_in_full_count
      @outstanding_count = result.outstanding_count
      @recent_payments = result.recent_payments
      @dashboard_message = StaticPage.find_by(location: 'dashboard')&.message

      if @active_program && result.user_rows.any?
        @pagy, @user_rows = pagy_array(result.user_rows, items: 20)
      else
        @pagy = nil
        @user_rows = result.user_rows
      end
    end
  end
end
