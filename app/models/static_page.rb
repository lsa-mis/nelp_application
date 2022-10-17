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
  has_rich_text :message
end
