# frozen_string_literal: true

module Support
  module Providers
    class LocationsCheckController < SupportController
      before_action :new_form

      def show; end

      def update
        if @location_form.save!
          if params.keys.include?('another')
            redirect_to new_support_recruitment_cycle_provider_location_path
          else
            redirect_to support_recruitment_cycle_provider_locations_path
          end
          flash[:success] = t('support.providers.locations.added')
        else
          render template: 'support/locations/new'
        end
      end

      private

      def new_form
        @location_form = LocationForm.new(provider, site)
      end

      def site
        @site ||= provider.sites.build
      end

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end
    end
  end
end
