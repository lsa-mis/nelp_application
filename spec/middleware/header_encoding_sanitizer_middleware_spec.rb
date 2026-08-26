# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HeaderEncodingSanitizerMiddleware do
  subject(:middleware) { described_class.new(app) }

  let(:app) { ->(env) { [200, { 'Content-Type' => 'text/plain' }, [env['HTTP_USER_AGENT'].to_s]] } }

  def call_with(headers: {})
    env = Rack::MockRequest.env_for('/')
    headers.each { |key, value| env[key] = value }
    middleware.call(env)
  end

  it 'passes through valid UTF-8 headers unchanged' do
    status, _headers, body = call_with(headers: { 'HTTP_USER_AGENT' => 'Mozilla/5.0' })

    expect(status).to eq(200)
    expect(body).to eq(['Mozilla/5.0'])
  end

  it 're-encodes non-UTF-8 headers so Rack/Rails can process them' do
    latin1 = 'café'.encode(Encoding::ISO_8859_1)

    status, _headers, body = call_with(headers: { 'HTTP_USER_AGENT' => latin1 })

    expect(status).to eq(200)
    expect(body.first.encoding).to eq(Encoding::UTF_8)
    expect(body.first).to eq('café')
  end

  it 'scrubs invalid byte sequences instead of raising' do
    invalid = "bad\xFF".dup.force_encoding(Encoding::ASCII_8BIT)

    expect { call_with(headers: { 'HTTP_USER_AGENT' => invalid }) }.not_to raise_error

    _status, _headers, body = call_with(headers: { 'HTTP_USER_AGENT' => invalid })
    expect(body.first.encoding).to eq(Encoding::UTF_8)
    expect(body.first.valid_encoding?).to be(true)
  end

  it 'sanitizes CONTENT_TYPE as well as HTTP_* headers' do
    captured = nil
    inspecting_app = lambda do |env|
      captured = env['CONTENT_TYPE']
      [200, {}, ['OK']]
    end
    middleware = described_class.new(inspecting_app)
    latin1 = 'text/plain; charset=iso-8859-1; name=café'.encode(Encoding::ISO_8859_1)

    env = Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => latin1)
    middleware.call(env)

    expect(captured.encoding).to eq(Encoding::UTF_8)
    expect(captured).to include('café')
  end

  it 'leaves non-header env keys alone' do
    captured = nil
    inspecting_app = lambda do |env|
      captured = env['rack.session.options']
      [200, {}, ['OK']]
    end
    middleware = described_class.new(inspecting_app)
    options = { id: 'abc' }

    env = Rack::MockRequest.env_for('/')
    env['rack.session.options'] = options
    middleware.call(env)

    expect(captured).to equal(options)
  end
end
