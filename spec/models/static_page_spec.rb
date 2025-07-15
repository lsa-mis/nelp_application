# == Schema Information
#
# Table name: static_pages
#
#  id         :bigint           not null, primary key
#  location   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe StaticPage, type: :model do
  subject { described_class.new(location: "about") }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a location" do
    subject.location = nil
    expect(subject).not_to be_valid
  end
end
