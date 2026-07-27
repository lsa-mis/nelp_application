# frozen_string_literal: true

module Admin
  class ProgramSettingsController < BaseController
    before_action :set_program_setting, only: %i[show edit update destroy]

    def index
      @pagy, @program_settings = pagy(ProgramSetting.order(program_year: :desc))
    end

    def show; end

    def new
      @program_setting = ProgramSetting.new
    end

    def create
      @program_setting = ProgramSetting.new(program_setting_params)
      if @program_setting.save
        redirect_to admin_program_setting_path(@program_setting), notice: 'Program setting was successfully created.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit; end

    def update
      if @program_setting.update(program_setting_params)
        redirect_to admin_program_setting_path(@program_setting), notice: 'Program setting was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @program_setting.destroy!
      redirect_to admin_program_settings_path, notice: 'Program setting was successfully destroyed.'
    end

    private

    def set_program_setting
      @program_setting = ProgramSetting.find(params[:id])
    end

    def program_setting_params
      params.require(:program_setting).permit(
        :program_year, :application_fee, :program_fee, :active, :program_open, :program_close,
        :open_instructions, :close_instructions, :payment_instructions, :allow_payments
      )
    end
  end
end
