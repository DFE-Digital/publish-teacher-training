# frozen_string_literal: true

module Support
  module Providers
    class AccreditedProvidersController < SupportController
      include ClearStashable

      helper_method :accredited_provider_id

      before_action :reset_accredited_provider_form, only: %i[index]

      def index
        @accredited_providers = provider.accrediting_providers.order(:provider_name).page(params[:page] || 1)
        render layout: 'provider_record'
      end

      def new
        provider
        accredited_provider_form
      end

      def create
        @accredited_provider_form = AccreditedProviderForm.new(current_user, params: accredited_provider_params)
        if @accredited_provider_form.stash
          redirect_to check_support_recruitment_cycle_provider_accredited_providers_path
        else
          provider
          render :new
        end
      end

      private

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end

      def accredited_provider_id
        @accredited_provider_form.accredited_provider_id || params[:accredited_provider_id]
      end

      def accredited_provider_form
        @accredited_provider_form ||= AccreditedProviderForm.new(current_user)
      end

      def accredited_provider_params
        params.require(:support_accredited_provider_form)
              .except(:goto_confirmation)
              .permit(AccreditedProviderForm::FIELDS)
      end
    end
  end
end
