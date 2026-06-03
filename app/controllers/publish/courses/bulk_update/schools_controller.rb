module Publish
  module Courses
    module BulkUpdate
      class SchoolsController < ApplicationController
        include CourseBasicDetailConcern

        before_action :build_course
        before_action :load_school_changes, only: %i[edit check]

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

          "subject_science" => {
            scope: "All science courses",
            short: "Science courses",
          },
        }.freeze

        SCIENCE_SUBJECT_NAMES = %w[
          Biology
          Chemistry
          Physics
          Science
        ].freeze

        COURSE_STATUSES = [
          { label: "Open", colour: "blue" },
          { label: "Rolled over", colour: "yellow" },
          { label: "Closed", colour: "red" },
        ].freeze

        def edit
          @bulk_options = []

          # Always allow just this course
          @this_course_option = OpenStruct.new(
            id: "this_course",
            name: "Only this course - #{course.name_and_code}",
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
              name: "All school direct salaried courses",
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
          # if course.qualifications_summary&.include?("PGCE")
          #   @bulk_options << OpenStruct.new(
          #     id: "pgce",
          #     name: "All QTS with PGCE courses",
          #   )
          # end

          # if course.qualifications_summary == "QTS"
          #   @bulk_options << OpenStruct.new(
          #     id: "qts",
          #     name: "All QTS only courses",
          #   )
          # end

          # Study mode–based options
          # if course.full_time?
          #   @bulk_options << OpenStruct.new(
          #     id: "full_time",
          #     name: "All full time courses",
          #   )
          # end

          # if course.part_time?
          #   @bulk_options << OpenStruct.new(
          #     id: "part_time",
          #     name: "All part time courses",
          #   )
          # end

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

          # if course.subjects.any?
          #   subject = course.subjects.first

          #   @bulk_options << OpenStruct.new(
          #     id: "subject_#{subject.id}",
          #     name: "All #{subject.name.downcase} courses",
          #   )
          # end

          # # if science course then offer to update all science courses (biology / chemistry / physics)
          # if course.subjects.any? { |s| SCIENCE_SUBJECT_NAMES.include?(s.name) }
          #   @bulk_options << OpenStruct.new(
          #     id: "subject_science",
          #     name: "All science courses",
          #   )
          # end

          # Subject-based options vs single subject options
          if science_course?
            @bulk_options << OpenStruct.new(
              id: "subject_science",
              name: "All science courses",
              hint: "Biology, chemistry, physics, science",
            )
          elsif course.subjects.any?
            subject = course.subjects.first

            @bulk_options << OpenStruct.new(
              id: "subject_#{subject.id}",
              name: "All #{subject.name.downcase} courses",
            )
          end

          # Always allow all courses
          @bulk_options << OpenStruct.new(
            id: "all",
            name: "All courses",
          )

          @this_course_hint = course_hint_text.join(", ")
        end

        def update
          redirect_to check_bulk_schools_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
            bulk_apply: params[:bulk_apply], # pass through the bulk option selected on the edit page so it can be applied on the check page
            added_count: params[:added_count], # pass through the counts so they can be displayed on the check page without having to recalculate them
            removed_count: params[:removed_count],
            added_site_ids: params[:added_site_ids],
            removed_site_ids: params[:removed_site_ids],
          )
        end

        def confirm
          flash[:success] = "Schools updated on #{selected_courses_count(params[:bulk_apply])} courses"

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        end

        def check
          @bulk_apply = params[:bulk_apply]

          case @bulk_apply
          when "subject_science"
            @bulk_apply_scope_label = "All science courses"
            @bulk_apply_short_label = course_hint_text

          when /^subject_/
            subject_id = @bulk_apply.delete_prefix("subject_")
            subject = Subject.find(subject_id)

            @bulk_apply_scope_label = "All #{subject.name.downcase} courses"
            @bulk_apply_short_label = course_hint_text

          else
            labels = BULK_APPLY_LABELS[@bulk_apply]

            @bulk_apply_scope_label = labels[:scope]
            @bulk_apply_short_label =
              if @bulk_apply == "this_course"
                [course.name_and_code]
              else
                course_hint_text
              end
          end

          @courses_for_check =
            Array.new(selected_courses_count(@bulk_apply)) do |index|
              {
                name: "Course name (X#{(index + 1).to_s.rjust(3, '0')})",
                status: COURSE_STATUSES.sample,
                info: @bulk_apply_short_label,
              }
            end

          @show_courses_table = @bulk_apply != "this_course" && @bulk_apply != "all"
        end

        def selected_courses_count(scope)
          scope == "this_course" ? 1 : 20
        end

      private

        def science_course?
          course.subjects.any? { |s| SCIENCE_SUBJECT_NAMES.include?(s.name) }
        end

        def course_hint_text
          [
            ("Fee-paying" if course.fee?),
            ("School direct salaried" if course.salary?),
            ("QTS" if course.qualifications_summary == "QTS"),
            ("QTS with PGCE" if course.qualifications_summary&.include?("PGCE")),
            ("full time" if course.full_time?),
            ("part time" if course.part_time?),
          ].compact
        end

        def load_school_changes
          @added_count   = params[:added_count].to_i
          @removed_count = params[:removed_count].to_i

          @added_site_ids   = Array(params[:added_site_ids]).map(&:to_i)
          @removed_site_ids = Array(params[:removed_site_ids]).map(&:to_i)

          # Turn IDs to school names for display in the view
          site_ids = @added_site_ids + @removed_site_ids

          sites_by_id =
            Site.where(id: site_ids).index_by(&:id)

          @added_schools =
            @added_site_ids.map { |id| sites_by_id[id] }.compact

          @removed_schools =
            @removed_site_ids.map { |id| sites_by_id[id] }.compact
        end
      end
    end
  end
end
