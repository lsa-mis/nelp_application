# frozen_string_literal: true

module AdminUsers
  class PasswordsController < Devise::PasswordsController
    layout 'admin'
  end
end
