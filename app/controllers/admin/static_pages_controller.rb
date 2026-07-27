# frozen_string_literal: true

module Admin
  class StaticPagesController < BaseController
    before_action :set_static_page, only: %i[edit update]

    def index
      @pagy, @static_pages = pagy(StaticPage.order(:location))
    end

    def edit; end

    def update
      if @static_page.update(static_page_params)
        redirect_to admin_static_pages_path, notice: 'Static page was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_static_page
      @static_page = StaticPage.find(params[:id])
    end

    def static_page_params
      params.require(:static_page).permit(:location, :message)
    end
  end
end
