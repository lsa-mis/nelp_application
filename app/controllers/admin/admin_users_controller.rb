# frozen_string_literal: true

module Admin
  class AdminUsersController < BaseController
    before_action :set_admin_user, only: %i[show edit update destroy]

    def index
      scope = AdminUser.order(:email)
      scope = scope.where('email ILIKE ?', "%#{params[:email]}%") if params[:email].present?
      @pagy, @admin_users = pagy(scope)
    end

    def show; end

    def new
      @admin_user = AdminUser.new
    end

    def create
      @admin_user = AdminUser.new(admin_user_params)
      if @admin_user.save
        redirect_to admin_admin_user_path(@admin_user), notice: 'Admin user was successfully created.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit; end

    def update
      attrs = admin_user_params
      attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?

      if @admin_user.update(attrs)
        redirect_to admin_admin_user_path(@admin_user), notice: 'Admin user was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @admin_user.destroy!
      redirect_to admin_admin_users_path, notice: 'Admin user was successfully destroyed.'
    end

    private

    def set_admin_user
      @admin_user = AdminUser.find(params[:id])
    end

    def admin_user_params
      params.require(:admin_user).permit(:email, :password, :password_confirmation)
    end
  end
end
