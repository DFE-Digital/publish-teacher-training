# frozen_string_literal: true

module Support
  module Providers
    class CopyCoursesController < ApplicationController
      before_action :recruitment_cycle

      def new
        @target_provider = Provider.find(params[:provider_id])
        @copy_courses_form = CopyCoursesForm.new(@target_provider)
      end

      def create
        @target_provider = Provider.find(params[:provider_id])
        @copy_courses_form = CopyCoursesForm.new(@target_provider, recruitment_cycle.providers.find_by(provider_code: params[:course][:autocompleted_provider_code]))

        if @copy_courses_form.valid?
          copy_provider_schools_to_target if copy_schools?

          copier = ::Courses::CopyToProviderService.new(
            schools_copy_to_course: schools_copy_to_course_service,
            sites_copy_to_course: Sites::CopyToCourseService,
            enrichments_copy_to_course: Enrichments::CopyToCourseService.new,
            force: true,
          )

          Provider.transaction do
            @copy_courses_form.provider.courses.map do |course|
              copier.execute(course:, new_provider: @copy_courses_form.target_provider)
            end
          end

          @courses_copied = copier.courses_copied
          @courses_not_copied = copier.courses_not_copied
          flash[:success] = "Courses copied: #{@courses_copied.map(&:course_code).sort.to_sentence}"
          flash[:warning] = "Courses not copied: #{@courses_not_copied.map(&:course_code).to_sentence}"

          redirect_to support_recruitment_cycle_provider_courses_path(recruitment_cycle.year, @copy_courses_form.target_provider.id)
        else
          render :new
        end
      end

    private

      def copy_schools?
        params[:schools].present?
      end

      def copy_provider_schools_to_target
        Rollover::Schools::ProviderCopier.new.execute(
          provider: @copy_courses_form.provider,
          new_provider: @copy_courses_form.target_provider,
        )
      end

      def schools_copy_to_course_service
        return ->(**) {} unless copy_schools?

        Rollover::Schools::DualCourseCopier.new(
          legacy_copier: Rollover::Schools::LegacyCourseCopier.new(site_copier: Sites::CopyToCourseService),
          new_copier: Rollover::Schools::CourseCopier.new,
        )
      end
    end
  end
end
