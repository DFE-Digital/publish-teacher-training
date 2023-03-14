# frozen_string_literal: true

module Support
  module Providers
    module Locations
      class CheckMultipleController < SupportController
        def show
          school_details
        end

        def update
          save
          redirect_to support_recruitment_cycle_provider_locations_path
        end

        private

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end

        def save
          school_details.each(&:save)

          parsed_csv_school_form.clear_stash
          raw_csv_school_form.clear_stash
        end

        def parsed_csv_school_form
          @parsed_csv_school_form ||= ParsedCSVSchoolsForm.new(provider)
        end

        def raw_csv_school_form
          @raw_csv_school_form ||= RawCSVSchoolsForm.new(provider)
        end

        def school_details
          @school_details ||= parsed_csv_school_form.school_details.map { |s| Site.new(s) }
        end
      end
    end
  end
end
