require 'digest'
require 'time'

class PaymentsController < ApplicationController
  devise_group :logged_in, contains: [:user, :admin_user]
  before_action :authenticate_logged_in!
  before_action :authenticate_admin!, only: [:index, :destroy]

  def index
    redirect_to root_url and return unless admin_user_signed_in?
    @payments = Payment.current_program_payments
  end

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

      redirect_to all_payments_path, notice: "Your Payment Was Successfully Recorded"
    end
  end

  def make_payment
    processed_url = generate_hash(current_user, params['amount'])
    redirect_to processed_url
  end

  def payment_show
    @total_cost = current_program.program_fee.to_i  + current_program.application_fee.to_i
    @users_current_payments = Payment.where(program_year: current_program.program_year, user_id: current_user )
    @ttl_paid = Payment.where(program_year: current_program.program_year, user_id: current_user, transaction_status: '1').pluck(:total_amount).map(&:to_f).sum / 100
    @balance_due = @total_cost - @ttl_paid
  end

  private
    def generate_hash(current_user, amount=current_program.application_fee.to_i)
      user_account = current_user.email.partition('@').first + '-' + current_user.id.to_s
      redirect_url = 'https://lsa-english-nelp-app.miserver.it.umich.edu/payment_receipt'
      amount_to_be_payed = amount.to_i
      if Rails.env.development? || Rails.application.credentials.NELNET_SERVICE[:SERVICE_SELECTOR] == "QA"
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
       'prod_URL' => Rails.application.credentials.NELNET_SERVICE[:PRODUCTION_URL]
      }
      current_epoch_time = DateTime.now.strftime("%Q").to_i
      initial_hash = {
        'orderNumber' => user_account,
        'orderType' => Rails.application.credentials.NELNET_SERVICE[:ORDERTYPE],
        'orderDescription' => 'NELP Application Fees',
        'amountDue' => amount_to_be_payed * 100,
        'redirectUrl' => redirect_url,
        'redirectUrlParameters' => 'transactionType,transactionStatus,transactionId,transactionTotalAmount,transactionDate,transactionAcountType,transactionResultCode,transactionResultMessage,orderNumber',
        'retriesAllowed' => 1,
        'timestamp' => current_epoch_time,
        'key' => connection_hash[key_to_use]
      }

      # Sample Hash Creation
      hash_to_be_encoded = initial_hash.values.map{|v| "#{v}"}.join('')
      encoded_hash =  Digest::SHA256.hexdigest hash_to_be_encoded

      # Final URL
      url_for_payment = initial_hash.map{|k,v| "#{k}=#{v}&" unless k == 'key'}.join('')
      final_url = connection_hash[url_to_use] + url_for_payment + 'hash=' + encoded_hash
    end

    def url_params
      params.permit(:amount, :transactionType, :transactionStatus, :transactionId, :transactionTotalAmount, :transactionDate, :transactionAcountType, :transactionResultCode, :transactionResultMessage, :orderNumber, :timestamp, :hash, :program_year)
    end
end

