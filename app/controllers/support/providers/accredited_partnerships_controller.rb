# frozen_string_literal: true

module Support
  module Providers
    class AccreditedPartnershipsController < ApplicationController
      helper_method :accredited_provider_id

      def index
        @pagy, @partnerships = pagy(provider.accredited_partnerships)
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
          provider_id: @provider.id,
        ), flash: { success: t(".removed") }
      end

    private

      def cannot_delete
        @cannot_delete ||= provider.courses.exists?(accredited_provider_code: params[:accredited_provider_code])
      end

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end

      def accredited_provider_id
        params[:accredited_provider_id]
      end

      def partner
        recruitment_cycle.providers.find_by(provider_code: params[:accredited_provider_code])
      end
    end
  end
end
