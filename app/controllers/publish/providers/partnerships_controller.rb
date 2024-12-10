# frozen_string_literal: true

module Publish
  module Providers
    class PartnershipsController < PublishController
      def index; end

      def show; end

      def new; end

      def edit; end

      def create
        redirect_to publish_provider_recruitment_cycle_partnerships_path(@provider, recruitment_cycle.year)
      end

      def update
        @partnership = if provider.accredited?
                         partnerships.find_by(training_provider_id: partner.id)
                       else
                         partnerships.find_by(accredited_provider: partner.id)
                       end

        redirect_to publish_provider_recruitment_cycle_partnership_path(@provider, recruitment_cycle.year, @partnership.id)
      end

      def destroy
        @partnership = if provider.accredited?
                         partnerships.find_by(training_provider_id: partner.id)
                       else
                         partnerships.find_by(accredited_provider: partner.id)
                       end
        redirect_to publish_provider_recruitment_cycle_partnerships_path(@provider, recruitment_cycle.year)
      end

      private

      def provider
        @provider = recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
      end

      def partner
        recruitment_cycle.providers.find_by(provider_code: params[:partner_provider_code])
      end

      def partnerships
        provider.accredited? ? provider.training_partnerships : provider.accredited_partnerships
      end
    end
  end
end
