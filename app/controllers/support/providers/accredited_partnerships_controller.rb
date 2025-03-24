# frozen_string_literal: true

module Support
  module Providers
    class AccreditedPartnershipsController < ApplicationController
      include ClearStashable

      helper_method :accredited_provider_id

      before_action :reset_accredited_provider_form, only: %i[index]

      def index
        @pagy, @partnerships = pagy(provider.accredited_partnerships)
      end

      def new
        partnership = provider.accredited_partnerships.build
        partnership.assign_attributes(accredited_provider_id: params[:accredited_provider_id] || ProviderPartnershipForm.new(current_user, provider).accredited_provider_id)

        @accredited_provider_form = ProviderPartnershipForm.new(current_user, partnership)
        return unless partnership.invalid?

        redirect_to search_support_recruitment_cycle_provider_accredited_providers_path(RecruitmentCycle.current.year), flash: { error: { message: "#{Provider.find(params[:accredited_provider_id]).name_and_code} partnership already exists" } }
      end

      def edit
        partnership = provider.accredited_partnerships.find_by(accredited_provider: partner)
        params = { accredited_provider_id: partner.id, description: partnership.description }
        @accredited_provider_form = ::ProviderPartnershipForm.new(current_user, partnership, params:)
      end

      def create
        @accredited_provider_form = ::ProviderPartnershipForm.new(current_user, provider, params: accredited_provider_params)

        if @accredited_provider_form.stash
          redirect_to check_support_recruitment_cycle_provider_accredited_partnerships_path(accredited_provider_id: partnership_params[:accredited_provider_id])
        else
          render :new
        end
      end

      def update
        partnership = provider.accredited_partnerships.find_by(accredited_provider: partner)
        @accredited_provider_form = ::ProviderPartnershipForm.new(current_user, partnership, params: accredited_provider_params)

        if @accredited_provider_form.save!
          redirect_to support_recruitment_cycle_provider_accredited_partnerships_path(
            recruitment_cycle_year: @recruitment_cycle.year,
            provider_id: @provider.id
          ), flash: { success: t('.updated') }

        else
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

        redirect_to support_recruitment_cycle_provider_accredited_partnerships_path(
          recruitment_cycle_year: @recruitment_cycle.year,
          provider_id: @provider.id
        ), flash: { success: t('.removed') }
      end

      private

      def cannot_delete
        @cannot_delete ||= provider.courses.exists?(accredited_provider_code: params[:accredited_provider_code])
      end

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end

      def accredited_provider_id
        params[:accredited_provider_id] || @accredited_provider_form.accredited_provider_id
      end

      def accredited_provider_form
        @accredited_provider_form ||= ::ProviderPartnershipForm.new(current_user, provider, params: { accredited_provider_id: params[:accredited_provider_id] })
      end

      def accredited_provider_params
        params.require(:provider_partnership_form)
              .except(:goto_confirmation)
              .permit(::ProviderPartnershipForm::FIELDS)
      end

      def partner
        recruitment_cycle.providers.find_by(provider_code: params[:accredited_provider_code])
      end

      def partnership_params
        params.expect(provider_partnership_form: %i[accredited_provider_id description])
      end
    end
  end
end
