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
class ProgramSetting < ApplicationRecord
    validates :program_year, presence: true, uniqueness: true
    validates :program_open, :program_close, presence: true
    validate :only_one_active_camp

    def self.ransackable_attributes(auth_object = nil)
      ["active", "allow_payments", "application_fee", "close_instructions", "created_at", "id", "open_instructions", "payment_instructions", "program_close", "program_fee", "program_open", "program_year", "updated_at"]
    end

    scope :active_program, -> { where(active: true) }

    def total_cost
        self.program_fee + self.application_fee
    end

    def only_one_active_camp
        return unless active?
      
        matches = ProgramSetting.active_program
        if persisted?
          matches = matches.where('id != ?', id)
        end
        if matches.exists?
          errors.add(:active, 'cannot have another active program')
        end
      end
end
