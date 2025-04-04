# frozen_string_literal: true

module Support
  module Providers
    class AccreditedProvidersController < ApplicationController
      include ClearStashable

      helper_method :accredited_provider_id

      before_action :reset_accredited_provider_form, only: %i[index]

      def index
        @pagy, @accredited_providers = pagy(provider.accrediting_providers.order(:provider_name))
      end

      def new
        accredited_provider_form
      end

      def edit
        provider
        accredited_provider
        @accredited_provider_form = ::AccreditedProviderForm.new(current_user, provider, params: provider.accredited_body(params[:accredited_provider_code]))
      end

      def create
        @accredited_provider_form = ::AccreditedProviderForm.new(current_user, provider, params: accredited_provider_params)
        if @accredited_provider_form.stash
          redirect_to check_support_recruitment_cycle_provider_accredited_providers_path
        else
          render :new
        end
      end

      def update
        @accredited_provider_form = ::AccreditedProviderForm.new(current_user, provider, params: accredited_provider_params)

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

      def delete
        cannot_delete
      end

      def destroy
        return if cannot_delete

        provider.accrediting_provider_enrichments = accrediting_provider_enrichments
        provider.save

        flash[:success] = t('support.providers.accredited_providers.delete.updated')

        redirect_to support_recruitment_cycle_provider_accredited_providers_path(
          recruitment_cycle_year: @recruitment_cycle.year,
          provider_id: @provider.id
        )
      end

      private

      def cannot_delete
        @cannot_delete ||= provider.courses.exists?(accredited_provider_code: accredited_provider.provider_code)
      end

      def accrediting_provider_enrichments
        provider.accrediting_provider_enrichments.reject { |enrichment| enrichment.UcasProviderCode == params['accredited_provider_code'] }
      end

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
        @accredited_provider_form ||= ::AccreditedProviderForm.new(current_user, provider)
      end

      def accredited_provider_params
        params.require(:accredited_provider_form)
              .except(:goto_confirmation)
              .permit(::AccreditedProviderForm::FIELDS)
      end
    end
  end
end
