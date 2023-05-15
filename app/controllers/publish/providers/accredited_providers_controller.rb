# frozen_string_literal: true

module Publish
  module Providers
    class AccreditedProvidersController < PublishController
      helper_method :accredited_provider_id

      before_action :authorize_provider

      def index
        provider
      end

      def new
        provider
        accredited_provider_form
      end

      def create
        @accredited_provider_form = AccreditedProviderForm.new(current_user, params: accredited_provider_params)
        if @accredited_provider_form.stash
          redirect_to check_publish_provider_recruitment_cycle_accredited_providers_path(@provider.provider_code, @provider.recruitment_cycle_year)
        else
          provider
          render :new
        end
      end

      def provider
        @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code] || params[:code])
      end

      def authorize_provider
        authorize(provider)
      end

      def accredited_provider_id
        @accredited_provider_form.accredited_provider_id || params[:accredited_provider_id]
      end

      def accredited_provider_form
        @accredited_provider_form ||= AccreditedProviderForm.new(current_user)
      end

      def accredited_provider_params
        params.require(:publish_accredited_provider_form)
              .except(:goto_confirmation)
              .permit(AccreditedProviderForm::FIELDS)
      end
    end
  end
end
