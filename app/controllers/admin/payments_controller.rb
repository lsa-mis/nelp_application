# frozen_string_literal: true

module Admin
  class PaymentsController < BaseController
    before_action :set_payment, only: %i[show edit update]

    def index
      scope = Payment.includes(:user).order(created_at: :desc)
      scope = apply_filters(scope)
      @pagy, @payments = pagy(scope)
      @users = User.order(:email)
      @program_years = Payment.distinct.order(:program_year).pluck(:program_year)
      @account_types = Payment.distinct.order(:account_type).pluck(:account_type).compact
    end

    def show; end

    def new
      @payment = Payment.new(
        transaction_type: '1',
        transaction_status: '1',
        transaction_date: Time.current.strftime('%Y%m%d%H%M'),
        program_year: current_program&.program_year || Date.current.year
      )
    end

    def create
      @payment = Payment.new(payment_params)
      if @payment.save
        redirect_to admin_payment_path(@payment), notice: 'Payment was successfully created.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit; end

    def update
      if @payment.update(payment_params)
        redirect_to admin_payment_path(@payment), notice: 'Payment was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_payment
      @payment = Payment.includes(:user).find(params[:id])
    end

    def apply_filters(scope)
      scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
      scope = scope.where(program_year: params[:program_year]) if params[:program_year].present?
      scope = scope.where(account_type: params[:account_type]) if params[:account_type].present?
      if params[:created_at_from].present?
        scope = scope.where(payments: { created_at: Time.zone.parse(params[:created_at_from]).beginning_of_day.. })
      end
      if params[:created_at_to].present?
        scope = scope.where(payments: { created_at: ..Time.zone.parse(params[:created_at_to]).end_of_day })
      end
      scope
    end

    def payment_params
      params.require(:payment).permit(
        :transaction_type, :transaction_status, :transaction_id, :total_amount, :transaction_date,
        :account_type, :result_code, :result_message, :user_account, :payer_identity, :timestamp,
        :transaction_hash, :user_id, :program_year
      )
    end
  end
end
