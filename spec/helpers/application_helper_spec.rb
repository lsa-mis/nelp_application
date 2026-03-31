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

  describe '#sentry_trace_propagation_meta' do
    it 'returns safe empty string when sentry metadata raises an argument error' do
      stub_const('Sentry', Class.new do
        def self.get_trace_propagation_meta
          'trace-meta'
        end
      end)
      allow(Sentry).to receive(:get_trace_propagation_meta).and_raise(ArgumentError)

      expect(helper.sentry_trace_propagation_meta).to eq('')
    end
  end
end
