# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class ChecksController < ApplicationController
        helper_method :school_id
        before_action :site

        def show; end

        def update
          ActiveRecord::Base.transaction do
            # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
            # TODO School data remodel removal - remove this legacy Site write when provider schools are created only in Provider::School.
            ::ProviderSchools::LegacySiteCreator.call(site: @site)
            # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
            ::ProviderSchools::Creator.call(
              provider: @provider,
              gias_school_id: school_id,
              site_code: @site.code,
              uuid: @site.uuid,
            )
          end

          redirect_to publish_provider_recruitment_cycle_schools_path, flash: { success_with_body: { title: t(".added"), body: @site.location_name } }
        rescue ActiveRecord::RecordInvalid
          render :show
        end

      private

        # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
        # TODO School data remodel removal - remove when the school check page builds a Provider::School instead of a Site.
        def site
          @site ||= begin
            gias_school = GiasSchool.find(school_id)
            @provider.sites.school.build(gias_school.school_attributes)
          end
        end
        # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

        def school_id
          # params[:school_id] comes from the school search
          # site: school_id comes from the checks#show form
          params[:school_id] || params.expect(site: [:school_id])[:school_id]
        end
      end
    end
  end
end
