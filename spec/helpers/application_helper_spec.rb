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

  describe '#demote_action_text_h1' do
    it 'returns a blank safe string for blank input' do
      expect(helper.demote_action_text_h1(nil)).to eq('')
      expect(helper.demote_action_text_h1('')).to eq('')
      expect(helper.demote_action_text_h1(nil)).to be_html_safe
    end

    it 'returns plain text unchanged' do
      expect(helper.demote_action_text_h1('Welcome to NELP')).to eq('Welcome to NELP')
    end

    it 'demotes opening and closing h1 tags to h2 while keeping attributes' do
      html = '<h1 class="x">Title</h1>'
      result = helper.demote_action_text_h1(html)

      expect(result).to eq('<h2 class="x">Title</h2>')
      expect(result).to be_html_safe
    end

    it 'demotes multiple h1 tags case-insensitively' do
      html = '<H1>One</H1><p>mid</p><h1 id="two">Two</h1>'
      expect(helper.demote_action_text_h1(html)).to eq('<h2>One</h2><p>mid</p><h2 id="two">Two</h2>')
    end
  end
end
