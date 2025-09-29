require 'digest'
require 'time'
class PaymentsController < ApplicationController
  devise_group :logged_in, contains: %i[user admin_user]
  before_action :authenticate_logged_in!
  before_action :ensure_current_program

  def payment_receipt
    if Payment.pluck(:transaction_id).include?(params['transactionId'])
      redirect_to all_payments_path
    else
      Payment.create(
        transaction_type: params['transactionType'],
        transaction_status: params['transactionStatus'],
        transaction_id: params['transactionId'],
        total_amount: params['transactionTotalAmount'],
        transaction_date: params['transactionDate'],
        account_type: params['transactionAcountType'],
        result_code: params['transactionResultCode'],
        result_message: params['transactionResultMessage'],
        user_account: params['orderNumber'],
        payer_identity: current_user.email,
        timestamp: params['timestamp'],
        transaction_hash: params['hash'],
        user_id: current_user.id,
        program_year: current_program.program_year
      )

      redirect_to all_payments_path, notice: 'Your Payment Was Successfully Recorded'
    end
  end

  def make_payment
    amount = params['amount'] || current_program.application_fee.to_i
    processed_url = generate_hash(current_user, amount)
    redirect_to processed_url, allow_other_host: true
  end

  def payment_show
    @total_cost = current_program.program_fee.to_i + current_program.application_fee.to_i
    @users_current_payments = Payment.where(program_year: current_program.program_year, user_id: current_user)
    @ttl_paid = Payment.where(program_year: current_program.program_year, user_id: current_user,
                              transaction_status: '1').pluck(:total_amount).map(&:to_f).sum / 100
    @balance_due = Payment.current_balance_due_for_user(current_user, current_program.program_year)
  end

  private

  def generate_hash(current_user, amount = current_program.application_fee.to_i)
    user_account = "#{current_user.email.partition('@').first}-#{current_user.id}"
    amount_to_be_payed = amount.to_i
    if Rails.env.development? || Rails.env.staging? ||
       Rails.application.credentials.NELNET_SERVICE[:SERVICE_SELECTOR] == 'QA'
      key_to_use = 'test_key'
      url_to_use = 'test_URL'
    else
      key_to_use = 'prod_key'
      url_to_use = 'prod_URL'
    end

    connection_hash = {
      'test_key' => Rails.application.credentials.NELNET_SERVICE[:DEVELOPMENT_KEY],
      'test_URL' => Rails.application.credentials.NELNET_SERVICE[:DEVELOPMENT_URL],
      'prod_key' => Rails.application.credentials.NELNET_SERVICE[:PRODUCTION_KEY],
      'prod_URL' => Rails.application.credentials.NELNET_SERVICE[:PRODUCTION_URL],
    }
    redirect_url = connection_hash[url_to_use]
    current_epoch_time = DateTime.now.strftime('%Q').to_i
    initial_hash = {
      orderNumber: user_account,
      orderType: Rails.application.credentials.NELNET_SERVICE[:ORDERTYPE],
      orderDescription: 'NELP Application Fees',
      amountDue: amount_to_be_payed * 100,
      redirectUrl: redirect_url,
      redirectUrlParameters: 'transactionType,transactionStatus,transactionId,' \
                             'transactionTotalAmount,transactionDate,' \
                             'transactionAcountType, transactionResultCode,' \
                             'transactionResultMessage,orderNumber',
      retriesAllowed: 1,
      timestamp: current_epoch_time,
      key: connection_hash[key_to_use],
    }

    # Sample Hash Creation
    hash_to_be_encoded = initial_hash.values.map(&:to_s).join
    encoded_hash =  Digest::SHA256.hexdigest hash_to_be_encoded

    # Final URL
    url_for_payment = initial_hash.map { |k, v| "#{k}=#{v}&" unless k == 'key' }.join
    "#{connection_hash[url_to_use]}?#{url_for_payment}hash=#{encoded_hash}"
  end

  def url_params
    params.permit(:amount, :transactionType, :transactionStatus, :transactionId,
                  :transactionTotalAmount, :transactionDate, :transactionAcountType,
                  :transactionResultCode, :transactionResultMessage, :orderNumber,
                  :timestamp, :hash, :program_year)
  end

  def ensure_current_program
    return if current_program

    redirect_to root_path, alert: 'Program not found. Please contact support.'
  end
end
