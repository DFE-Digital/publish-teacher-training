# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class MultipleController < SupportController
        def new
          @raw_csv_schools_form = RawCSVSchoolsForm.new(provider)
        end

        def create
          @raw_csv_schools_form = RawCSVSchoolsForm.new(provider, params: form_params)
          if @raw_csv_schools_form.stash

            school_details = CSVImports::LocationsService.call(csv_content: @raw_csv_schools_form.school_details, provider:)
            ParsedCSVSchoolsForm.new(provider, params: { school_details: }).stash
            redirect_to support_recruitment_cycle_provider_schools_multiple_new_path(position: 1)
          else
            render(:new)
          end
        end

        private

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
