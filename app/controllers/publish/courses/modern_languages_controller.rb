module Publish
  module Courses
    class ModernLanguagesController < PublishController
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
      before_action :build_course_params, only: [:continue]
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        return if has_modern_languages_subject?

        redirect_to next_step
      end

      def continue
        super
      end

      def edit
        authorize(provider)

        return if selected_non_language_subjects_ids.include? modern_languages_subject_id.to_s

        redirect_to(
          details_publish_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          ),
        )
      end

      def update
        authorize(provider)

        if course_subjects_form.save!
          flash[:success] = I18n.t("success.saved")
          binding.pry
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

      def back
        authorize(@provider, :edit?)
        if has_modern_languages_subject?
          redirect_to new_publish_provider_recruitment_cycle_courses_modern_languages_path(path_params)
        else
          redirect_to @back_link_path
        end
      end

      def current_step
        :modern_languages
      end

    private

      def updated_subject_list
        @updated_subject_list ||= selected_language_subjects_ids.concat(selected_non_language_subjects_ids)
      end

      def course_subjects_form
        @course_subjects_form ||= CourseSubjectsForm.new(@course, params: updated_subject_list)
      end

      def error_keys
        [:modern_languages_subjects]
      end

      def modern_languages_subject_id
        @modern_languages_subject_id ||= @course.edit_course_options[:modern_languages_subject].id
      end

      def selected_subjects(param_key)
        edit_course_options_key = param_key == :language_ids ? :modern_languages : :subjects

        ids = params.dig(:course, param_key)&.map(&:to_i) || []

        @course.edit_course_options[edit_course_options_key].filter_map do |subject|
          subject.id.to_s if ids.include?(subject.id)
        end
      end

      def selected_language_subjects_ids
        selected_subjects(:language_ids)
      end

      def selected_non_language_subjects_ids
        selected_subjects(:subjects_ids)
      end

      def has_modern_languages_subject?
        @course.subjects.any? { |subject| subject.id == modern_languages_subject_id }
      end

      def build_course_params
        build_new_course # to get languages edit_options
        params[:course][:subjects_ids] = selected_non_language_subject_ids
        params[:course][:subjects_ids] += params[:course][:language_ids] if params[:course][:language_ids]
        params[:course].delete(:language_ids)
      end

      def non_language_subject_ids
        @course.edit_course_options[:subjects].map(&:id).map(&:to_s)
      end

      def selected_non_language_subject_ids
        non_language_subject_ids & params[:course][:subjects_ids]
      end
    end
  end
end
