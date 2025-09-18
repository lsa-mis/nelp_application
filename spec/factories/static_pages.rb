# == Schema Information
#
# Table name: static_pages
#
#  id         :bigint           not null, primary key
#  location   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :static_page do
    message { nil }
    location { 'MyString' }
  end
end
