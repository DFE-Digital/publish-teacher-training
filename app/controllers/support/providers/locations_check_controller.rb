# frozen_string_literal: true

module Support
  module Providers
    class LocationsCheckController < SupportController
      def show
        site = provider.sites.build
        @location_form = LocationForm.new(provider, site)
      end

      def update
        @site = provider.sites.build
        @location_form = LocationForm.new(provider, @site)
        # Should we do something else here?
        return unless @location_form.save!

        if params.keys.include?('another')
          redirect_to new_support_recruitment_cycle_provider_location_path
        else
          redirect_to support_recruitment_cycle_provider_locations_path
        end
        flash[:success] = t('support.providers.locations.added')
      end

      private

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end
    end
  end
end
