module Publish
  module Courses
    module BulkUpdate
      class BulkUpdateSchoolExperienceController < ApplicationController
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
          flash[:success] = "School experience updated on #{selected_courses_count(params[:bulk_update_scope])} courses"

          redirect_to publish_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          )
        end

      private

        def assign_bulk_update_options
          @target_scope_label = @course.apprenticeship? ? "apprenticeship courses" : "school direct salaried courses"
          @target_course_type_label = @course.apprenticeship? ? "Apprenticeship" : "School direct salaried"

          @bulk_options = []
          @bulk_options << OpenStruct.new(id: "all_apprenticeship", name: "All #{@target_scope_label}")

          if @course.qualifications_summary == "QTS"
            @bulk_options << OpenStruct.new(id: "qts_only", name: "All QTS only, #{@target_scope_label}")
          end

          if @course.qualifications_summary&.include?("PGCE")
            @bulk_options << OpenStruct.new(id: "qts_with_pgce", name: "All QTS with PGCE, #{@target_scope_label}")
          end

          if @course.full_time?
            @bulk_options << OpenStruct.new(id: "full_time", name: "All full time, #{@target_scope_label}")
          end

          if @course.part_time?
            @bulk_options << OpenStruct.new(id: "part_time", name: "All part time, #{@target_scope_label}")
          end

          if @course.primary_course?
            @bulk_options << OpenStruct.new(id: "primary", name: "All primary, #{@target_scope_label}")
          end

          if @course.secondary_course?
            @bulk_options << OpenStruct.new(id: "secondary", name: "All secondary, #{@target_scope_label}")
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
