# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class CheckMultipleController < ApplicationController
        include SuccessMessage

        def show
          schools
          unfound_urns
          duplicate_urns
        end

        def update
          save

          redirect_to support_recruitment_cycle_provider_schools_path
        end

        def remove_school
          if urn_form.values.present?
            updated_values = urn_form.values - [params[:urn]]
            @urn_form = URNForm.new(provider, params: { values: updated_values })
            @urn_form.stash
          end
          schools
          unfound_urns
          duplicate_urns

          flash.now[:success] = t(".school_removed")
          render :show
        end

      private

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end

        def save
          saved_schools = []

          gias_schools.each do |gias_school|
            ActiveRecord::Base.transaction do
              saved_schools << create_provider_school(gias_school:)
            end
          end

          schools_added_message(saved_schools)
        end

        def create_provider_school(gias_school:)
          if provider_school_identity.after_schools_remodel_cycle?
            return ::ProviderSchools::Creator.call(provider:, gias_school_id: gias_school.id)
          end

          # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
          # TODO School data remodel removal - remove this legacy Site write when support creates Provider::School directly.
          legacy_site = provider.sites.build(gias_school.school_attributes)
          ::ProviderSchools::LegacySiteCreator.call(site: legacy_site)
          # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

          ::ProviderSchools::Creator.call(
            provider:,
            gias_school_id: gias_school.id,
            site_code: legacy_site.code,
            uuid: legacy_site.uuid,
          )
        end

        def provider_school_identity
          @provider_school_identity ||= ::ProviderSchools::Identity.new(provider:)
        end

        def urn_form
          @urn_form ||= URNForm.new(provider)
        end

        def urn_service
          @urn_service ||= ProviderURNIdentificationService.new(provider, urn_form.values || []).call
        end

        def gias_schools
          @gias_schools ||= GiasSchool.where(urn: urn_service[:new_urns])
        end

        # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
        # TODO School data remodel removal - remove when support multiple-school checks no longer preview unsaved Site rows.
        def schools
          @schools ||= gias_schools.map { |gias_school| provider.sites.build(gias_school.school_attributes) }
        end
        # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

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
