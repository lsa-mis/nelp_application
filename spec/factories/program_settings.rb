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
FactoryBot.define do
  factory :program_setting do
    sequence(:program_year) { |n| Date.current.year + n }
    program_fee { 1000 }
    application_fee { 500 }
    active { false }
    program_open { 1.month.from_now }
    program_close { 6.months.from_now }
    open_instructions { "Welcome to the NELP program! Applications are now open." }
    close_instructions { "The application period has ended. Thank you for your interest." }
    payment_instructions { "Please use the secure payment link below to submit your fees." }
    allow_payments { false }

    trait :active do
      active { true }
      allow_payments { true }
    end

    trait :closed do
      program_open { 2.months.ago }
      program_close { 1.month.ago }
      active { false }
      allow_payments { false }
    end

    trait :future do
      program_open { 2.months.from_now }
      program_close { 8.months.from_now }
    end

    trait :no_fees do
      program_fee { 0 }
      application_fee { 0 }
    end

    trait :high_fees do
      program_fee { 2000 }
      application_fee { 1000 }
    end
  end
end
