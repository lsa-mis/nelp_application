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
FactoryBot.define do
  factory :payment do
    transaction_type { '1' }
    transaction_status { '1' } # Successful by default
    sequence(:transaction_id) { |n| "TXN#{Time.current.strftime('%Y%m%d')}#{n.to_s.rjust(6, '0')}" }
    total_amount { '50000' } # $500 in cents
    transaction_date { Date.current.strftime('%Y%m%d%H%M') }
    account_type { 'VISA' }
    result_code { '1' }
    result_message { 'APPROVED' }
    user_account { |p| "#{p.user&.email&.split('@')&.first || 'user'}-#{p.user&.id || 1}" }
    payer_identity { |p| p.user&.email || 'user@example.com' }
    timestamp { Time.current.to_i.to_s }
    sequence(:transaction_hash) { |n| Digest::SHA256.hexdigest("payment_hash_#{n}") }
    program_year { Date.current.year }

    association :user

    # Traits for different payment scenarios
    trait :failed do
      transaction_status { '0' }
      result_code { '1001' }
      result_message { 'DECLINED' }
    end

    trait :pending do
      transaction_status { '2' }
      result_code { '0001' }
      result_message { 'PENDING' }
    end

    trait :refund do
      transaction_type { 'REFUND' }
      total_amount { '-25000' } # Negative amount for refund
      result_message { 'REFUNDED' }
    end

    trait :large_amount do
      total_amount { '150000' } # $1500 in cents
    end

    trait :small_amount do
      total_amount { '1000' } # $10 in cents
    end

    trait :mastercard do
      account_type { 'MASTERCARD' }
    end

    trait :amex do
      account_type { 'AMEX' }
    end

    trait :discover do
      account_type { 'DISCOVER' }
    end

    # Historical payment traits
    trait :last_year do
      program_year { Date.current.year - 1 }
      transaction_date { 1.year.ago.strftime('%Y%m%d%H%M') }
    end

    trait :two_years_ago do
      program_year { Date.current.year - 2 }
      transaction_date { 2.years.ago.strftime('%Y%m%d%H%M') }
    end
  end
end
