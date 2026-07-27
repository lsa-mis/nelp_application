# frozen_string_literal: true

module AdminUsers
  class SessionsController < Devise::SessionsController
    layout 'admin'

    def after_sign_in_path_for(_resource)
      admin_root_path
    end

    def after_sign_out_path_for(_resource_or_scope)
      new_admin_user_session_path
    end
  end
end
