module Publish
  module Courses
    module BulkUpdate
      class SchoolsController < ApplicationController
        include CourseBasicDetailConcern

        before_action :build_course

        BULK_APPLY_LABELS = {
          "all" => {
            scope: "All courses",
            short: "All courses",
          },
          "fee" => {
            scope: "All fee‑paying courses",
            short: "Fee‑paying",
          },
          "salary" => {
            scope: "All school direct salaried courses",
            short: "Salaried",
          },
          "apprenticeship" => {
            scope: "All apprenticeship courses",
            short: "Apprenticeship",
          },
          "full_time" => {
            scope: "All full time courses",
            short: "Full time",
          },
          "part_time" => {
            scope: "All part time courses",
            short: "Part time",
          },
          "primary" => {
            scope: "All primary courses",
            short: "Primary",
          },
          "secondary" => {
            scope: "All secondary courses",
            short: "Secondary",
          },
          "pgce" => {
            scope: "All QTS with PGCE courses",
            short: "QTS with PGCE",
          },
          "qts" => {
            scope: "All QTS only courses",
            short: "QTS only",
          },
          "this_course" => {
            scope: "Only this course",
            short: "This course only",
          },
        }.freeze

        # def edit
        #   @bulk_options = [
        #     OpenStruct.new(id: "all", name: "All courses"),
        #     OpenStruct.new(id: "full_time", name: "All full time courses"),
        #     OpenStruct.new(id: "pgce", name: "All QTS with PGCE courses"),
        #     OpenStruct.new(
        #       id: "this_course",
        #       name: "Only this course – #{course.name_and_code}",
        #     ),
        #   ]
        # end

        def edit
          @bulk_options = []

          # Always allow all courses
          @bulk_options << OpenStruct.new(
            id: "all",
            name: "All courses",
          )

          # Fee or salary
          if course.fee?
            @bulk_options << OpenStruct.new(
              id: "fee",
              name: "All fee‑paying courses",
            )
          end

          if course.salary?
            @bulk_options << OpenStruct.new(
              id: "salary",
              name: "All school direct salaried course (not apprenticeship courses)",
            )
          end

          if course.apprenticeship?
            @bulk_options << OpenStruct.new(
              id: "apprenticeship",
              name: "All apprenticeship courses",
            )
          end

          # Qualification options
          # PGCE‑style
          if course.qualifications_summary&.include?("PGCE")
            @bulk_options << OpenStruct.new(
              id: "pgce",
              name: "All QTS with PGCE courses",
            )
          end

          if course.qualifications_summary == "QTS"
            @bulk_options << OpenStruct.new(
              id: "qts",
              name: "All QTS only courses",
            )
          end

          # Study mode–based options
          if course.full_time?
            @bulk_options << OpenStruct.new(
              id: "full_time",
              name: "All full time courses",
            )
          end

          if course.part_time?
            @bulk_options << OpenStruct.new(
              id: "part_time",
              name: "All part time courses",
            )
          end

          # Primary/secondary options
          if course.primary_course?
            @bulk_options << OpenStruct.new(
              id: "primary",
              name: "All primary courses",
            )
          end

          if course.secondary_course?
            @bulk_options << OpenStruct.new(
              id: "secondary",
              name: "All secondary courses",
            )
          end

          # Always allow just this course
          @bulk_options << OpenStruct.new(
            id: "this_course",
            name: "Only this course – #{course.name_and_code}",
          )
        end

        def update
          redirect_to check_bulk_schools_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
            bulk_apply: params[:bulk_apply], # pass through the bulk option selected on the edit page so it can be applied on the check page
          )
        end

        def confirm
          flash[:success] = I18n.t("success.saved", value: "Schools")

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        end

        def check
          @bulk_apply = params[:bulk_apply]

          labels = BULK_APPLY_LABELS[@bulk_apply]

          @bulk_apply_scope_label = labels[:scope]
          @bulk_apply_short_label =
            if @bulk_apply == "this_course"
              course.name_and_code
            else
              labels[:short]
            end

          # only show courses table if user has selected a bulk option that applies to multiple courses (i.e. not "this course only" or "all courses")
          @show_courses_table = !%w[all this_course].include?(@bulk_apply)
        end
      end
    end
  end
end
