module Publish
  module Courses
    class SubjectsController < PublishController
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
      before_action :build_course_params, only: [:continue]
      include CourseBasicDetailConcern

      def edit
        authorize(provider)
      end

      def continue
        super
      end

      def update
        authorize(provider)

        if selected_subject_ids.include?(modern_languages_subject_id.to_s)
          redirect_to(
            modern_languages_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
              course: { subjects_ids: selected_subject_ids },
            ),
          )

        elsif course_subjects_form.save!
          value = @course.is_primary? ? "primary subject" : "secondary subject"
          flash[:success] = @course.only_published? ? I18n.t("success.value_published", value: value) : I18n.t("success.value_saved", value: value)

          redirect_to(
            details_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
            ),
          )
        else
          @errors = @course.errors.messages
          render :edit
        end
      end

    private

      def course_subjects_form
        @course_subjects_form ||= CourseSubjectsForm.new(@course, params: selected_subject_ids)
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
        @selected_master ||= params[:course][:master_subject_id] if params[:course][:master_subject_id].present?
      end

      def selected_subordinate
        @selected_subordinate ||= params[:course][:subordinate_subject_id] if params[:course][:subordinate_subject_id].present?
      end

      def build_course_params
        previous_subject_selections = params[:course][:subjects_ids]

        params[:course][:subjects_ids] = selected_subject_ids

        params[:course].delete(:master_subject_id)
        params[:course].delete(:subordinate_subject_id)

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
    end
  end
end
