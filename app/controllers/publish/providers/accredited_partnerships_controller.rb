# frozen_string_literal: true

module Publish
  module Providers
    class AccreditedPartnershipsController < ApplicationController
      helper_method :accredited_provider_id

      def index; end

      def show
        @provider = provider
        @accredited_provider = partner
      end

      def delete
        @provider_partnership = provider.accredited_partnerships.find_by(accredited_provider: partner)
        cannot_delete
      end

      def destroy
        @partnership = provider.accredited_partnerships.find_by(accredited_provider_id: partner.id)

        if @partnership.destroy
          flash[:success] = t(".removed")
          redirect_to publish_provider_recruitment_cycle_accredited_partnerships_path(@provider.provider_code, recruitment_cycle.year)
        else
          render :delete
        end
      end

    private

      def cannot_delete
        @cannot_delete ||= provider.courses.exists?(accredited_provider_code: params[:accredited_provider_code])
      end

      def provider
        @provider = recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
      end

      def partner
        recruitment_cycle.providers.find_by(provider_code: params[:accredited_provider_code])
      end
    end
  end
end
