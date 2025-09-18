class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :current_program

  # private
  def current_program
    ProgramSetting.active_program.last
  rescue StandardError
    flash.now[:alert] = 'There are no active programs!'
  end

  helper_method :current_program

  def current_program_open?
    return false unless current_program

    program_range = current_program.program_open..current_program.program_close
    program_range.cover?(Time.zone.now)
  end

  helper_method :current_program_open?
end
