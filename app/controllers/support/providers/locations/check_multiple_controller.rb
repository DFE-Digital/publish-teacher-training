# frozen_string_literal: true

module Support
  module Providers
    module Locations
      class CheckMultipleController < SupportController

        def show
          @raw_csv_schools_form = RawCSVSchoolsForm.new(provider)
        end

        private

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end
      end
    end
  end
end
