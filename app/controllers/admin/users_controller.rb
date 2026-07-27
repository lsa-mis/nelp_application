# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      scope = User.order(:email)
      scope = scope.where(id: Payment.users_with_zero_balance.select(:id)) if params[:scope] == 'zero_balance'
      scope = scope.where(email: params[:email]) if params[:email].present?
      @pagy, @users = pagy(scope)
      @emails = User.order(:email).pluck(:email)
    end

    def show
      @user = User.find(params[:id])
      @pagy, @payments = pagy(@user.payments.order(created_at: :desc))
    end
  end
end
