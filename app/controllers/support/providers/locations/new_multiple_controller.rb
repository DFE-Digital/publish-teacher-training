# frozen_string_literal: true

module Support
  module Providers
    module Locations
      class NewMultipleController < SupportController
        def show
          site
          max
          provider
          @multiple_locations_form = MultipleLocationsForm.new(current_user, current_user)
        end

        def update
          site.assign_attributes(site_params)
          site.provider = provider

          if site.valid? && params[:position].to_i < max
            redirect_to support_recruitment_cycle_provider_locations_multiple_new_path(position: params[:position].to_i + 1)
          elsif params[:position].to_i == max
            redirect_to support_recruitment_cycle_provider_locations_path
          else
            max
            render(:show)
          end
        end

        def site_params
          params.require(:site).permit(
            :location_name,
            :urn,
            :code,
            :address1,
            :address2,
            :address3,
            :address4,
            :postcode
          )
        end

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end

        def sites
          [Site.new(location_name: 'A'), Site.new(location_name: 'B')]
        end

        def max
          @max ||= sites.count
        end

        def site
          @site ||= sites[array_index]
        end

        def array_index
          params[:position].to_i - 1
        end
      end
    end
  end
end
