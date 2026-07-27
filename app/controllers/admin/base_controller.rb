# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Pagy::Backend

    layout 'admin'

    before_action :authenticate_admin_user!

    helper_method :current_admin_user
  end
end
