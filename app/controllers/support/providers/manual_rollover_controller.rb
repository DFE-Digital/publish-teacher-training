# frozen_string_literal: true

module Support
  module Providers
    class ManualRolloverController < ApplicationController
      before_action :set_provider

      def new
        @provider_manual_rollover_form = Support::Providers::ManualRolloverForm.new
      end

      def confirm
        @provider_manual_rollover_form = Support::Providers::ManualRolloverForm.new(form_params)

        if @provider_manual_rollover_form.valid?
          RolloverProviderService.call(
            provider_code: @provider.provider_code,
            new_recruitment_cycle_id: @provider.recruitment_cycle.next.id,
            force: true,
          )
          flash[:success] = t(".success")
          redirect_to support_recruitment_cycle_provider_path(@provider.recruitment_cycle_year, @provider)
        else
          render :new
        end
      end

    private

      def set_provider
        @provider = Provider.find(params[:id])
      end

      def form_params
        params.fetch(:support_providers_manual_rollover_form, {}).permit(:confirmation, :environment)
      end
    end
  end
end
