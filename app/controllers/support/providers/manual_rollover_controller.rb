# frozen_string_literal: true

module Support
  module Providers
    class ManualRolloverController < ApplicationController
      before_action :set_provider
      before_action :redirect_to_provider, only: :confirm, unless: -> { @provider.can_be_rolled_over? }

      def new
        @provider_manual_rollover_form = Support::Providers::ManualRolloverForm.new(provider: @provider)
      end

      def confirm
        @provider_manual_rollover_form = Support::Providers::ManualRolloverForm.new(form_params.merge(provider: @provider))

        if @provider_manual_rollover_form.valid? && rolled_over?
          flash[:success] = t(".success")
          redirect_to_provider
        else
          render :new
        end
      end

    private

      def set_provider
        @provider = Provider.find(params[:id])
      end

      def redirect_to_provider
        redirect_to support_recruitment_cycle_provider_path(@provider.recruitment_cycle_year, @provider)
      end

      def rolled_over?
        ActiveRecord::Base.transaction do
          result = RolloverProviderService.call(
            provider_code: @provider.provider_code,
            recruitment_cycle_id: @provider.recruitment_cycle_id,
            new_recruitment_cycle_id: @provider.recruitment_cycle.next.id,
            course_codes: @provider_manual_rollover_form.chosen_course_codes,
            force: true,
          )
          next true if result[:courses_failed].empty?

          @provider_manual_rollover_form.errors.add(
            :base,
            :rollover_failed,
            course_codes: result[:courses_failed].pluck(:course_code).to_sentence,
          )
          raise ActiveRecord::Rollback
        end
      end

      def form_params
        params.fetch(:support_providers_manual_rollover_form, {}).permit(:confirmation, :environment, course_codes: [])
      end
    end
  end
end
