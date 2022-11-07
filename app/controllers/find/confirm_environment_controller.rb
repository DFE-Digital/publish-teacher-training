module Find
  class ConfirmEnvironmentController < ApplicationController
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
