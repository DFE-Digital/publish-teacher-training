# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class ChecksController < ApplicationController
        include TouchNoSchoolCourses

        before_action :new_form

        def show; end

        def update
          saved = false

          ActiveRecord::Base.transaction do
            saved = create_provider_school_with_legacy_site
            touch_all_no_school_courses if saved
          end

          if saved
            redirect_to support_recruitment_cycle_provider_schools_path
            flash[:success] = t(".added")
          else
            render :show
          end
        end

      private

        def new_form
          @school_form = SchoolForm.new(provider, site, params: { gias_school_id: params[:school_id] })
        end

        def create_provider_school_with_legacy_site
          # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
          # TODO School data remodel removal - replace this legacy Site-backed form save when support adds Provider::School directly.
          saved = @school_form.save!
          # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

          if saved
            ::ProviderSchools::Creator.call(
              provider:,
              gias_school_id: gias_school.id,
              site_code: @site.code,
              uuid: @site.uuid,
            )
          end

          saved
        end

        # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
        # TODO School data remodel removal - remove when support school checks build Provider::School directly.
        def site
          @site ||= @provider.sites.school.build(gias_school.school_attributes)
        end
        # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

        def gias_school
          @gias_school ||= GiasSchool.find(params[:school_id])
        end

        def provider
          @provider ||= Provider.find(params[:provider_id])
        end
      end
    end
  end
end
