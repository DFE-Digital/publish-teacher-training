module Find
  class ConfirmEnvironmentController < ApplicationController
    skip_before_action :redirect_to_maintenance_page_if_flag_is_active

    def new
      @confirmation = ConfirmEnvironment.new(from: params[:from])
    end

    def create
      @confirmation = ConfirmEnvironment.new(params.require(:find_confirm_environment).permit(:from, :environment))

      if @confirmation.valid?
        session[:confirmed_environment_at] = Time.zone.now
        redirect_to @confirmation.from
      else
        render :new
      end
    end
  end
end
