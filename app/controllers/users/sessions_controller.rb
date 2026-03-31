class Users::SessionsController < Devise::SessionsController
  def create
    sanitize_null_bytes_in_sign_in_params!
    super
  end

  private

  def sanitize_null_bytes_in_sign_in_params!
    auth_key = resource_name
    auth_params = params[auth_key]
    return unless auth_params.respond_to?(:to_unsafe_h)

    sanitized = sanitize_value(auth_params.to_unsafe_h)
    params[auth_key] = ActionController::Parameters.new(sanitized)
  end

  def sanitize_value(value)
    case value
    when String
      value.delete("\u0000")
    when Hash
      value.transform_values { |v| sanitize_value(v) }
    when Array
      value.map { |v| sanitize_value(v) }
    else
      value
    end
  end
end
