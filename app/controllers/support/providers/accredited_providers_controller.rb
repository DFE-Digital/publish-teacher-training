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
        accredited_provider_form
      end

      def edit
        provider
        accredited_provider
        @accredited_provider_form = AccreditedProviderForm.new(current_user, provider, params: provider.accredited_body(params[:accredited_provider_code]))
      end

      def create
        @accredited_provider_form = AccreditedProviderForm.new(current_user, provider, params: accredited_provider_params)
        if @accredited_provider_form.stash
          redirect_to check_support_recruitment_cycle_provider_accredited_providers_path
        else
          render :new
        end
      end

      def update
        @accredited_provider_form = AccreditedProviderForm.new(current_user, provider, params: accredited_provider_params)

        if @accredited_provider_form.save!
          redirect_to support_recruitment_cycle_provider_accredited_providers_path(
            recruitment_cycle_year: @recruitment_cycle.year,
            provider_id: @provider.id
          )

          flash[:success] = t('support.providers.accredited_providers.edit.updated')
        else
          accredited_provider
          render(:edit)
        end
      end

      private

      def accredited_provider
        @accredited_provider ||= @recruitment_cycle.providers.find_by(provider_code: params[:accredited_provider_code])
      end

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end

      def accredited_provider_id
        params[:accredited_provider_id] || @accredited_provider_form.accredited_provider_id
      end

      def accredited_provider_form
        @accredited_provider_form ||= AccreditedProviderForm.new(current_user, provider)
      end

      def accredited_provider_params
        params.require(:support_accredited_provider_form)
              .except(:goto_confirmation)
              .permit(AccreditedProviderForm::FIELDS)
      end
    end
  end
end
