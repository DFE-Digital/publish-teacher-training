module PublishInterface
  module Courses
    class ModernLanguagesController < PublishInterfaceController
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
      before_action :build_course_params, only: [:continue]
      before_action :build_provider, only: [:new]
      include CourseBasicDetailConcern

      def new
        # TODO: Create a :new? authorize method
        authorize(@provider, :edit?)
        return if has_modern_languages_subject?

        redirect_to next_step
      end

      def continue
        super
      end

      def edit
        return unless @course.edit_course_options[:modern_languages].nil?

        redirect_to(
          details_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          ),
        )
      end

      def update
        updated_subject_list = selected_language_subjects
        updated_subject_list += selected_non_language_subjects

        if @course.update(subjects: updated_subject_list)
          flash[:success] = I18n.t("success.saved")
          redirect_to(
            details_provider_recruitment_cycle_course_path(
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
          redirect_to new_provider_recruitment_cycle_courses_modern_languages_path(path_params)
        else
          redirect_to @back_link_path
        end
      end

      def current_step
        :modern_languages
      end

    private

      def build_provider
        @provider = RecruitmentCycle.find_by(year: params[:recruitment_cycle_year])
                      .providers
                      .find_by(provider_code: params[:provider_code])
      end

      def error_keys
        [:modern_languages_subjects]
      end

      def selected_language_subjects
        language_ids = params.dig(:course, :language_ids)
        if language_ids.present?
          found_languages_ids = available_languages_ids & language_ids
          found_languages_ids.map { |id| Subject.new(id: id) }
        else
          []
        end
      end

      def selected_non_language_subjects
        ids = params.dig(:course, :subjects_ids) || []

        ids.map do |id|
          Subject.new(id: id)
        end
      end

      def available_languages_ids
        @course.edit_course_options[:modern_languages].map do |language|
          language["id"]
        end
      end

      def build_course
        @course = Course
                    .includes(:subjects, :site_statuses)
                    .where(recruitment_cycle_year: params[:recruitment_cycle_year])
                    .where(provider_code: params[:provider_code])
                    .find(params[:code])
                    .first
      end

      def has_modern_languages_subject?
        modern_languages_subject_id = @course.edit_course_options[:modern_languages_subject][:id]
        @course.subjects.any? { |subject| subject[:id] == modern_languages_subject_id }
      end

      def build_course_params
        build_new_course # to get languages edit_options
        params[:course][:subjects_ids] = selected_non_language_subject_ids
        params[:course][:subjects_ids] += params[:course][:language_ids] if params[:course][:language_ids]
        params[:course].delete :language_ids
      end

      def non_language_subject_ids
        @course.edit_course_options[:subjects].map do |subject|
          subject["id"]
        end
      end

      def selected_non_language_subject_ids
        non_language_subject_ids & params[:course][:subjects_ids]
      end
    end
  end
end
