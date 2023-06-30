# frozen_string_literal: true

module Publish
  module Courses
    class StudySitesController < PublishController
      include CourseBasicDetailConcern

      def continue
        params[:course][:study_sites_ids].compact_blank!
        super
      end

      def new
        authorize(@provider, :edit?)
        return unless @provider.study_sites.one?

        set_default_study_site
        redirect_to next_step
      end

      def edit
        authorize(provider)
      end

      def update
        authorize(provider)

        update_course_study_sites

        if course.save
          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
          ), flash: { success: t('flash.updated', resource: 'Study sites') }
        else
          render :edit
        end
      end

      def back
        authorize(@provider, :edit?)
        redirect_to @provider.study_sites.many? ? new_publish_provider_recruitment_cycle_courses_study_sites_path(path_params) : @back_link_path
      end

      private

      def update_course_study_sites
        study_site_ids = params[:course][:study_sites]
        @study_sites ||= provider.study_sites.find(study_site_ids.compact_blank!)

        course.study_sites = @study_sites.select { |site| study_site_ids.include?(site.id.to_s) }
      end

      def current_step
        :study_site
      end

      def error_keys
        [:study_sites]
      end

      def set_default_study_site
        params['course'] ||= {}
        params['course']['study_sites_ids'] = [@provider.study_sites.first.id]
      end
    end
  end
end
