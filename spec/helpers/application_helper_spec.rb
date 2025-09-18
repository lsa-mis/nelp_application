require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#full_title' do
    it 'returns the base title when no page title is provided' do
      expect(helper.full_title).to eq('NELP Payments')
    end

    it 'returns the page title and base title when a page title is provided' do
      expect(helper.full_title('Help')).to eq('Help | NELP Payments')
    end
  end
end
