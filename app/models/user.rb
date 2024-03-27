# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  has_many :payments

  def self.ransackable_associations(auth_object = nil)
    ["payments"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "current_sign_in_at", "current_sign_in_ip", "email", "encrypted_password", "id", "last_sign_in_at", "last_sign_in_ip", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count", "updated_at"]
  end
  
  scope :zero_balance, -> { where(id: User.all.map { |u| u if u.balance_due_zero? }.compact)}

  def current_balance_due
    ProgramSetting.active_program.last.total_cost - self.payments.current_program_payments.pluck(:total_amount).sum(&:to_f) / 100
  end

  def balance_due_zero?
    self.current_balance_due.to_i == 0
  end

  def display_name
    self.email
  end
end
