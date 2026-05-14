module Publish
  module Courses
    module BulkUpdate
      class BulkUpdateFeesController < ApplicationController
        def edit
          @course = Course.find_by!(course_code: params[:code])
          assign_bulk_update_options
        end

        def review
          @course = Course.find_by!(course_code: params[:code])
          assign_bulk_update_options
        end

        def confirm
          @course = Course.find_by!(course_code: params[:code])
          flash[:success] = "Fees and financial support updated on #{selected_courses_count(params[:bulk_update_scope])} courses"

          redirect_to publish_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          )
        end

      private

        def assign_bulk_update_options
          @bulk_options = []
          @bulk_options << OpenStruct.new(id: "all_apprenticeship", name: "All fee-paying courses")

          if @course.qualifications_summary == "QTS"
            @bulk_options << OpenStruct.new(id: "qts_only", name: "All QTS fee-paying courses")
          end

          if @course.qualifications_summary&.include?("PGCE")
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
      end
    end
  end
end
