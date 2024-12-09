# frozen_string_literal: true

module Support
  module Providers
    class CopyCoursesController < SupportController
      before_action :recruitment_cycle

      def new
        @target_provider = Provider.find(params[:provider_id])
        @copy_courses_form = CopyCoursesForm.new(@target_provider)
      end

      def create
        @target_provider = Provider.find(params[:provider_id])
        @copy_courses_form = CopyCoursesForm.new(@target_provider, recruitment_cycle.providers.find_by(provider_code: params[:course][:autocompleted_provider_code]))

        if @copy_courses_form.valid?
          sites_copy_to_course = params[:schools] ? Sites::CopyToCourseService : ->(*) {}

          copier = ::Courses::CopyToProviderService.new(sites_copy_to_course:, enrichments_copy_to_course: Enrichments::CopyToCourseService.new, force: true)

          Provider.transaction do
            @copy_courses_form.provider.courses.map do |course|
              copier.execute(course:, new_provider: @copy_courses_form.target_provider)
            end
          end

          redirect_to support_recruitment_cycle_provider_path(recruitment_cycle.year, @copy_courses_form.target_provider.id)
        else
          render :new
        end
      end
    end
  end
end
