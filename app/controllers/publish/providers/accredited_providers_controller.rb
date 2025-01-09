# frozen_string_literal: true

module Publish
  module Providers
    class AccreditedProvidersController < ApplicationController
      helper_method :accredited_provider_id

      def index; end

      def new
        accredited_provider_form
      end

      def edit
        accredited_provider
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

        flash[:success] = t('publish.providers.accredited_providers.delete.updated')

        redirect_to publish_provider_recruitment_cycle_accredited_providers_path(provider.provider_code, provider.recruitment_cycle_year)
      end

      private

      def cannot_delete
        @cannot_delete ||= provider.courses.exists?(accredited_provider_code: accredited_provider.provider_code)
      end

      def accredited_provider
        @accredited_provider ||= @recruitment_cycle.providers.find_by(provider_code: params[:accredited_provider_code])
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

      def accrediting_provider_enrichments
        provider.accrediting_provider_enrichments.reject { |enrichment| enrichment.UcasProviderCode == params['accredited_provider_code'] }
      end
    end
  end
end
