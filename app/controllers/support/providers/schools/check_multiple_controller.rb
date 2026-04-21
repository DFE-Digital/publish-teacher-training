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
          saved_sites = []

          gias_schools.each do |gias_school|
            ActiveRecord::Base.transaction do
              provider_school = ::ProviderSchools::Creator.call(provider:, gias_school_id: gias_school.id)

              site = provider.sites.build(gias_school.school_attributes.merge(code: provider_school.site_code))
              ::ProviderSchools::LegacySiteCreator.call(site:)
              saved_sites << site
            end
          end

          schools_added_message(saved_sites)
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

        def schools
          @schools ||= gias_schools.map { |gias_school| provider.sites.build(gias_school.school_attributes) }
        end

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
