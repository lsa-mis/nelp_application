# == Schema Information
#
# Table name: static_pages
#
#  id         :bigint           not null, primary key
#  location   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StaticPage < ApplicationRecord
  validates :location, presence: true, uniqueness: true

  has_rich_text :message

  def self.ransackable_associations(_auth_object = nil)
    ['rich_text_message']
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id location updated_at]
  end
end
