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

  has_many :payments, dependent: :restrict_with_exception

  def self.ransackable_associations(_auth_object = nil)
    ['payments']
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at current_sign_in_at current_sign_in_ip email encrypted_password id last_sign_in_at
       last_sign_in_ip remember_created_at reset_password_sent_at reset_password_token sign_in_count updated_at]
  end

  # Delegators for payment logic (optional, for convenience)
  def current_balance_due(program_year = nil)
    program = ProgramSetting.active_program
    return 0 unless program

    Payment.current_balance_due_for_user(self, program_year)
  end

  def balance_due_zero?(program_year = nil)
    Payment.balance_due_zero_for_user?(self, program_year)
  end

  def display_name
    email
  end
end
