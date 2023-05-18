# frozen_string_literal: true

module Publish
  module Providers
    class AccreditedProvidersController < PublishController
      helper_method :accredited_provider_id

      before_action :authorize_provider, :provider

      def index  
      end

      def new
        accredited_provider_form
      end

      def edit
        @accredited_provider_form = AccreditedProviderForm.new(current_user, provider, params: provider.accredited_body(params[:accredited_provider_code]))
      end

      def create
        @accredited_provider_form = AccreditedProviderForm.new(current_user, provider, params: accredited_provider_params)

        if @accredited_provider_form.stash
          redirect_to check_publish_provider_recruitment_cycle_accredited_providers_path(@provider.provider_code, @provider.recruitment_cycle_year)
        else
          render :new
        end
      end

      def update
        @accredited_provider_form = AccreditedProviderForm.new(current_user, provider, params: accredited_provider_params)

        if @accredited_provider_form.save!
          redirect_to publish_provider_recruitment_cycle_accredited_providers_path(provider.provider_code, provider.recruitment_cycle_year)

          flash[:success] = t('publish.providers.accredited_providers.edit.updated')
        else
          render(:edit)
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
        @accredited_provider_form ||= AccreditedProviderForm.new(current_user, provider)
      end

      def accredited_provider_params
        params.require(:accredited_provider_form)
              .except(:goto_confirmation)
              .permit(AccreditedProviderForm::FIELDS)
      end
    end
  end
end
