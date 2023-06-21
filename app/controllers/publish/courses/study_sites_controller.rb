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
        return unless @provider.study_sites.count == 1

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
          )
        else
          render :edit
        end
      end

      private

      def update_course_study_sites
        study_site_ids = params[:course][:study_sites_ids]

        @study_sites ||= provider.study_sites.find(study_site_ids.compact_blank!)

        course.study_sites.delete(course.study_sites.reject { |study_site| study_site_ids.include?(study_site.id.to_s) })

        study_site_ids.each do |study_site_id|
          study_site = @study_sites.find { |site| site.id.to_s == study_site_id }
          course.study_sites << study_site unless course.study_sites.include?(study_site)
        end
      end

      def current_step
        :study_site
      end

      def set_default_study_site
        params['course'] ||= {}
        params['course']['study_sites_ids'] = [@provider.study_sites.first.id]
      end
    end
  end
end