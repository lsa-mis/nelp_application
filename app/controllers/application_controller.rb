class ApplicationController < ActionController::Base
    before_action :current_program 

    # private
    def current_program
        ProgramSetting.active_program.last unless nil
    rescue
        flash.now[:alert] = "There are no active programs!"
    end

    helper_method :current_program

    def current_program_open?
      if current_program 
        program_range = current_program.program_open..current_program.program_close
        program_range.cover?(Time.now)
      end
    end
  
    helper_method :current_program_open?

end
