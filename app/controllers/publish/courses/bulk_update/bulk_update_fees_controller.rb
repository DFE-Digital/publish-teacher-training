module Publish
  module Courses
    module BulkUpdate
      class BulkUpdateFeesController < ApplicationController
        def edit
          @course = course
          assign_bulk_update_options
        end

        def review
          @course = course
          assign_bulk_update_options
        end

        def confirm
          @course = course
          flash[:success] = "Fees and financial support updated on #{selected_courses_count(params[:bulk_update_scope])} courses"

          redirect_to publish_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          )
        end

      private

        def assign_bulk_update_options
          qualification_summary = @course.qualifications_summary.to_s.upcase

          @bulk_options = []
          @bulk_options << OpenStruct.new(id: "all_apprenticeship", name: "All fee-paying courses")

          if qualification_summary == "QTS"
            @bulk_options << OpenStruct.new(id: "qts_only", name: "All QTS fee-paying courses")
          end

          if qualification_summary.include?("PGCE")
            @bulk_options << OpenStruct.new(id: "qts_with_pgce", name: "All QTS with PGCE fee-paying courses")
          end

          if @course.full_time?
            @bulk_options << OpenStruct.new(id: "full_time", name: "All full time fee-paying courses")
          end

          if @course.part_time?
            @bulk_options << OpenStruct.new(id: "part_time", name: "All part time fee-paying courses")
          end

          @this_course_option = OpenStruct.new(
            id: "single_course",
            name: "Only this course - #{@course.name_and_code}",
          )
        end

        def selected_courses_count(scope)
          scope == "single_course" ? 1 : 20
        end

        def course
          @course ||= provider.courses.find_by!(course_code: params[:code])
        end
      end
    end
  end
end
