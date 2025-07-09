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
class Payment < ApplicationRecord
  belongs_to :user
  validates :transaction_id, presence: true, uniqueness: true
  validates :total_amount, presence: true
  validates :user_id, presence: true
  validates :program_year, presence: true

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["account_type", "created_at", "id", "payer_identity", "program_year", "result_code", "result_message", "timestamp", "total_amount", "transaction_date", "transaction_hash", "transaction_id", "transaction_status", "transaction_type", "updated_at", "user_account", "user_id"]
  end

  # New class method for filtering payments by program year
  def self.for_program_year(year)
    where(program_year: year)
  end

  # Calculates the current balance due for a user for a given program year
  def self.current_balance_due_for_user(user, program_year = nil)
    program = if program_year
      ProgramSetting.find_by(program_year: program_year)
    else
      ProgramSetting.active_program.last
    end
    return nil unless program
    paid = user.payments.where(program_year: program.program_year, transaction_status: '1')
                    .pluck(:total_amount).sum(&:to_f) / 100
    program.total_cost - paid
  end

  # Checks if the user's balance due is zero for a given program year
  def self.balance_due_zero_for_user?(user, program_year = nil)
    current_balance_due_for_user(user, program_year).to_i == 0
  end

  # Returns users with zero balance for a given program year
  def self.users_with_zero_balance(program_year = nil)
    User.all.select { |u| balance_due_zero_for_user?(u, program_year) }
  end

  def self.current_program_payments(program_year = Date.current.year)
    where(program_year: program_year)
  end
end
