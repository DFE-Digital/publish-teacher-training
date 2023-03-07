# frozen_string_literal: true

module Support
  module Providers
    module Locations
      class MultipleController < SupportController
        def new
          @raw_csv_schools_form = RawCSVSchoolsForm.new(provider)
        end

        def create
          @raw_csv_schools_form = RawCSVSchoolsForm.new(provider, params: form_params)
          if @raw_csv_schools_form.stash
            redirect_to support_recruitment_cycle_provider_locations_multiple_new_path(position: 1)
          else
            render(:new)
          end
        end

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end

        def form_params
          params.require(:support_raw_csv_schools_form).permit(:school_details)
        end
      end
    end
  end
end
