# frozen_string_literal: true

module Support
  class EnvironmentConfirmationsController < ApplicationController
    def new
      @confirmation = ConfirmEnvironment.new(from: params[:from])
    end

    def create
      @confirmation = ConfirmEnvironment.new(params.expect(support_confirm_environment: %i[from environment]))

      if @confirmation.valid?
        session[:confirmed_environment_at] = Time.zone.now

        redirect_to @confirmation.from
      else
        render :new
      end
    end
  end
end
