# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class ChecksController < ApplicationController
        helper_method :school_id
        before_action :site

        def show; end

        def update
          provider_school = ActiveRecord::Base.transaction do
            created = create_provider_school_and_legacy_site
            touch_all_no_school_courses
            created
          end

          redirect_to publish_provider_recruitment_cycle_schools_path,
                      flash: { success_with_body: { title: t(".added"), body: provider_school.gias_school.name } }
        rescue ActiveRecord::RecordInvalid
          render :show
        end

      private

        # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
        # TODO School data remodel removal - remove this legacy Site write when publish creates Provider::School directly.
        def create_provider_school_and_legacy_site
          ::ProviderSchools::LegacySiteCreator.call(site: @site)
          # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

          ::ProviderSchools::Creator.call(
            provider: @provider,
            gias_school_id: school_id,
            site_code: @site.code,
            uuid: @site.uuid,
          )
        end

        def site
          @site ||= @provider.sites.school.build(gias_school.school_attributes)
        end

        def touch_all_no_school_courses
          # `changed_at` has a UNIQUE index, so every row needs
          # its own timestamp. update_columns skips the provider touch, which
          # the provider school write has already done.
          @provider.courses.publishable_without_schools.find_each do |course|
            course.update_columns(changed_at: Time.zone.now)
          end
        end

        def gias_school
          @gias_school ||= GiasSchool.find(school_id)
        end

        def school_id
          # params[:school_id] comes from the school search
          # site: school_id comes from the checks#show form
          params[:school_id] || params.expect(site: [:school_id])[:school_id]
        end
      end
    end
  end
end
