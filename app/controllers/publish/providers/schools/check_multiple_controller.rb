# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class CheckMultipleController < ApplicationController
        include SuccessMessage
        before_action :set_urns_and_schools, only: %i[show]

        def show; end

        def update
          schools.each(&:save!)

          schools_added_message(schools)

          redirect_to publish_provider_recruitment_cycle_schools_path
        end

        def remove_school
          if urn_form.values.present?
            updated_values = urn_form.values - [params[:urn]]
            @urn_form = URNForm.new(provider, params: { values: updated_values })

            if updated_values.blank?
              @urn_form.clear_stash
            else
              @urn_form.stash
            end
          end

          set_urns_and_schools

          removed_school_name = GiasSchool.find_by(urn: params[:urn]).name

          flash.now[:success_with_body] = { "title" => t(".school_removed"), "body" => removed_school_name }
          render :show
        end

      private

        def set_urns_and_schools
          load_schools
          unfound_urns
          duplicate_urns
        end

        def provider
          @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
        end

        def urn_form
          @urn_form ||= URNForm.new(provider)
        end

        def urn_service
          @urn_service ||= ProviderURNIdentificationService.new(provider, urn_form.values || []).call
        end

        def schools
          @schools = begin
            gias_schools = GiasSchool.where(urn: urn_service[:new_urns])
            gias_schools.map do |gias_school|
              provider.sites.build(gias_school.school_attributes)
            end
          end
        end
        alias_method :load_schools, :schools

        def unfound_urns
          @unfound_urns = urn_service[:unfound_urns]
        end

        def duplicate_urns
          @duplicate_urns = urn_service[:duplicate_urns]
        end
      end
    end
  end
end
