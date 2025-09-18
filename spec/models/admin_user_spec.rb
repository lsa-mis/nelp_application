# == Schema Information
#
# Table name: admin_users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  subject { FactoryBot.build(:admin_user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'Devise modules' do
    it 'is database authenticatable' do
      expect(subject).to respond_to(:valid_password?)
    end

    it 'is recoverable' do
      expect(subject).to respond_to(:reset_password_token)
    end

    it 'is rememberable' do
      expect(subject).to respond_to(:remember_created_at)
    end
  end

  describe 'factory' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe '.ransackable_attributes' do
    it 'returns only safe attributes for searching' do
      expected_attributes = ['email']
      expect(described_class.ransackable_attributes).to match_array(expected_attributes)
    end

    it 'does not include sensitive attributes' do
      sensitive_attributes = %w[
        encrypted_password
        reset_password_token
        reset_password_sent_at
      ]

      ransackable = described_class.ransackable_attributes
      sensitive_attributes.each do |attr|
        expect(ransackable).not_to include(attr)
      end
    end
  end

  describe '.ransackable_associations' do
    it 'returns an empty array' do
      expect(described_class.ransackable_associations).to eq([])
    end
  end

  # Add more tests for custom methods or associations if present
end
