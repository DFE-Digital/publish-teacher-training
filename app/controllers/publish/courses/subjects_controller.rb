# frozen_string_literal: true

module Publish
  module Courses
    class SubjectsController < PublishController
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
      before_action :build_course_params, :campaign_name_check, only: [:continue]
      include CourseBasicDetailConcern

      def edit
        authorize(provider)
      end

      def continue
        super
      end

      def update
        authorize(provider)
        if params[:course][:master_subject_id] == SecondarySubject.physics.id.to_s
          course.update(master_subject_id: params[:course][:master_subject_id])
          redirect_to(
            engineers_teach_physics_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
              course: { master_subject_id: SecondarySubject.physics.id.to_s, subjects_ids: selected_subject_ids }
            )
          )

        elsif selected_subject_ids.include?(modern_languages_subject_id.to_s)
          course.update(master_subject_id: params[:course][:master_subject_id])
          redirect_to(
            modern_languages_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
              course: { subjects_ids: selected_subject_ids }
            )
          )

        elsif course_subjects_form.save!
          course_updated_message(section_key)
          # TODO: move this to the form?
          course.update(master_subject_id: params[:course][:master_subject_id])
          course.update(name: course.generate_name)
          course.update(campaign_name: nil) unless course.master_subject_id == SecondarySubject.physics.id

          redirect_to(
            details_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code
            )
          )
        else
          @errors = @course.errors.messages
          course.master_subject_id = selected_master
          course.subordinate_subject_id = selected_subordinate
          render :edit
        end
      end

      private

      def campaign_name_check
        params[:course][:campaign_name] = '' unless @course.master_subject_id == SecondarySubject.physics.id
      end

      def course_subjects_form
        @course_subjects_form ||= CourseSubjectsForm.new(@course, params: [selected_master, selected_subordinate])
      end

      def modern_languages_subject_id
        @modern_languages_subject_id ||= @course.edit_course_options[:modern_languages_subject].id
      end

      def selected_subject_ids
        @selected_subject_ids ||= [selected_master, selected_subordinate].compact
      end

      def current_step
        :subjects
      end

      def error_keys
        [:subjects]
      end

      def selected_master
        params[:course][:master_subject_id].presence
      end

      def selected_subordinate
        params[:course][:subordinate_subject_id].presence
      end

      def build_course_params
        previous_subject_selections = params[:course][:subjects_ids]

        params[:course][:subjects_ids] = selected_subject_ids

        build_new_course # to get languages edit_options

        previous_language_selections = selected_subject_ids.include?(modern_languages_subject_id.to_s) ? strip_non_language_subject_ids(previous_subject_selections) : []

        params[:course][:subjects_ids] = selected_subject_ids.concat(previous_language_selections)
      end

      def strip_non_language_subject_ids(subject_ids)
        return [] unless subject_ids

        subject_ids.filter { |id| available_languages_ids.include?(id) }
      end

      def available_languages_ids
        @course.edit_course_options[:modern_languages].map(&:id).map(&:to_s)
      end

      def section_key
        'Subject'.pluralize(selected_subject_ids.count)
      end
    end
  end
end
