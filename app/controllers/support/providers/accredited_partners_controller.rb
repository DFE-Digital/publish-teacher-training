# frozen_string_literal: true

module Support
  module Providers
    class AccreditedPartnersController < ApplicationController
      include ClearStashable

      helper_method :accredited_provider_id

      before_action :reset_accredited_provider_form, only: %i[index]

      def index
        @pagy, @accredited_partnerships = pagy(provider.accredited_partnerships)
        render layout: 'provider_record'
      end

      def new
        accredited_provider_form
      end

      def edit
        provider
        provider_partnership = provider.accredited_partnerships.find_by(accredited_provider: partner)
        params = { accredited_provider_id: partner.id, description: provider_partnership.description }
        @accredited_provider_form = ::ProviderPartnershipForm.new(current_user, provider_partnership, params:)
      end

      def create
        @accredited_provider_form = ::ProviderPartnershipForm.new(current_user, provider, params: accredited_provider_params)
        if @accredited_provider_form.stash
          redirect_to check_support_recruitment_cycle_provider_accredited_partners_path(accredited_provider_id: partnership_params[:accredited_provider_id])
        else
          render :new
        end
      end

      def update
        provider_partnership = provider.accredited_partnerships.find_by(accredited_provider: partner)
        @accredited_provider_form = ::ProviderPartnershipForm.new(current_user, provider_partnership, params: accredited_provider_params)

        if @accredited_provider_form.save!
          redirect_to support_recruitment_cycle_provider_accredited_partners_path(
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
        @accredited_provider = partner
      end

      def destroy
        return if cannot_delete

        provider.accredited_partnerships.find_by(accredited_provider_id: partner.id).destroy

        flash[:success] = t('support.providers.accredited_providers.delete.updated')

        redirect_to support_recruitment_cycle_provider_accredited_partners_path(
          recruitment_cycle_year: @recruitment_cycle.year,
          provider_id: @provider.id
        )
      end

      private

      def cannot_delete
        @cannot_delete ||= provider.courses.exists?(accredited_provider_code: partner.provider_code)
      end

      def accrediting_provider_enrichments
        provider.accrediting_provider_enrichments.reject { |enrichment| enrichment.UcasProviderCode == params['accredited_provider_code'] }
      end

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end

      def accredited_provider_id
        params[:accredited_provider_id] || @accredited_provider_form.accredited_provider_id
      end

      def accredited_provider_form
        @accredited_provider_form ||= ::ProviderPartnershipForm.new(current_user, partnership)
      end

      def accredited_provider_params
        params.require(:provider_partnership_form)
              .except(:goto_confirmation)
              .permit(::ProviderPartnershipForm::FIELDS)
      end

      def partner
        recruitment_cycle.providers.find_by(provider_code: params[:accredited_provider_code])
      end

      def partnership
        @partnership = provider.accredited_partnerships.find_or_initialize_by(accredited_provider: partner)
        @partnership.description ||= params[:description]
      end

      def partnership_params
        params.require(:provider_partnership_form).permit(:accredited_provider_id, :description)
      end
    end
  end
end
