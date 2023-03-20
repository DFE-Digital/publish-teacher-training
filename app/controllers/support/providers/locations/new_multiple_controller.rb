# frozen_string_literal: true

module Support
  module Providers
    module Locations
      class NewMultipleController < SupportController
        def show
          site
          max
        end

        def update
          site.assign_attributes(site_params)

          if site.valid?
            school_details[current_site_index] = site

            ParsedCSVSchoolsForm.new(provider, params: { school_details: }).stash

            if position == max || goto_confirmation?
              redirect_to support_recruitment_cycle_provider_locations_multiple_check_path
            elsif position < max
              redirect_to support_recruitment_cycle_provider_locations_multiple_new_path(position: position + 1)
            end
          else
            max
            render(:show)
          end
        end

        private

        def parsed_csv_school_form
          @parsed_csv_school_form ||= ParsedCSVSchoolsForm.new(provider)
        end

        def site_params
          params.require(:site)
                .except(:goto_confirmation)
                .permit(
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

        def school_details
          @school_details ||= parsed_csv_school_form.school_details.map { |s| Site.new(s) }
        end

        def max
          @max ||= school_details.count
        end

        def site
          @site ||= school_details[current_site_index]
        end

        def current_site_index
          @current_site_index = position - 1
        end

        def position
          @position ||= params[:position].to_i
        end

        def goto_confirmation? = params.dig(:site, :goto_confirmation) == 'true'
      end
    end
  end
end
