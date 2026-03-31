class HeaderEncodingSanitizerMiddleware
  HEADER_ENV_KEYS = /\AHTTP_/.freeze
  EXTRA_HEADER_KEYS = %w[CONTENT_TYPE CONTENT_LENGTH].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    sanitize_request_headers!(env)
    @app.call(env)
  end

  private

  def sanitize_request_headers!(env)
    env.each do |key, value|
      next unless header_key?(key)
      next unless value.is_a?(String)

      env[key] = sanitize_string(value)
    end
  end

  def header_key?(key)
    key.match?(HEADER_ENV_KEYS) || EXTRA_HEADER_KEYS.include?(key)
  end

  def sanitize_string(value)
    return value if value.encoding == Encoding::UTF_8 && value.valid_encoding?

    value.dup.encode(Encoding::UTF_8, value.encoding, invalid: :replace, undef: :replace, replace: '')
  rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
    value.dup.force_encoding(Encoding::UTF_8).scrub
  rescue StandardError
    ''
  end
end
