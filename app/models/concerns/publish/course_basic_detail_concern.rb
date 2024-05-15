# frozen_string_literal: true

module Publish
  module CourseBasicDetailConcern
    extend ActiveSupport::Concern

    included do
      decorates_assigned :course
      before_action :build_new_course, only: %i[back new continue]
      before_action :build_previous_course_creation_params, only: %i[new continue]
      before_action :build_meta_course_creation_params, only: %i[new continue]
      before_action :build_back_link, only: %i[new back continue]
      before_action :build_course, only: %i[edit update]
    end

    def back; end

    def new
      authorize(@provider, :can_create_course?)
    end

    def edit
      authorize(provider)
    end

    def update
      authorize(provider)

      @errors = errors
      return render :edit if @errors.present?

      if @course.update(course_params)
        course_updated_message(section_key)

        redirect_to(
          details_publish_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code
          )
        )
      else
        @errors = @course.errors.messages
        render :edit
      end
    end

    def continue
      authorize(@provider, :can_create_course?)
      @errors = errors

      if @errors.any?
        render :new
      else
        redirect_to next_step
      end
    end

    private

    def build_new_course
      add_custom_age_range_into_params if params.dig('course', 'age_range_in_years') == 'other'

      @course = ::Courses::CreationService.call(course_params:, provider:)
    end

    def build_course
      @course = provider.courses.find_by!(course_code: params[:code])
    end

    def add_custom_age_range_into_params
      params['course']['age_range_in_years'] = "#{age_from_param}_to_#{age_to_param}"
    end

    def errors
      @course.errors.messages.select { |key, _message| error_keys.include?(key) }
    end

    def error_keys
      []
    end

    def course_params
      if params.key? :course
        params.require(:course)
              .except(
                :day,
                :month,
                :year,
                :course_age_range_in_years_other_from,
                :course_age_range_in_years_other_to,
                :goto_confirmation,
                :skip_languages_goto_confirmation,
                :goto_visa,
                :language_ids
              ).permit(
                policy(Course.new).permitted_new_course_attributes,
                sites_ids: [],
                subjects_ids: [],
                study_sites_ids: []
              )
      else
        ActionController::Parameters.new({}).permit(:course)
      end
    end

    def build_previous_course_creation_params
      @course_creation_params = course_params
    end

    def build_meta_course_creation_params
      @meta_course_creation_params = params.slice(:skip_languages_goto_confirmation, :goto_confirmation, :goto_visa)
    end

    def continue_step
      if go_to_confirmation_params && %i[subjects apprenticeship funding_type].none?(current_step)
        :confirmation
      else
        CourseCreationStepService.new.execute(current_step:, course: @course)[:next]
      end
    end

    def next_step
      continue_path = course_creation_path_for(continue_step)

      raise "No path defined for continue step: #{continue_path}" if continue_path.nil?

      continue_path
    end

    def addtional_params
      {
        goto_confirmation: go_to_confirmation_params,
        goto_visa: params[:goto_visa]
      }.compact
    end

    def path_params
      { course: course_params }.merge(addtional_params)
    end

    def back_step
      if go_to_confirmation_params
        {
          modern_languages: :subjects,
          can_sponsor_student_visa: (@course.is_uni_or_scitt? ? :apprenticeship : :funding_type),
          can_sponsor_skilled_worker_visa: (@course.is_uni_or_scitt? ? :apprenticeship : :funding_type)
        }[current_step] || :confirmation
      else
        CourseCreationStepService.new.execute(current_step:, course: @course)[:previous]
      end
    end

    def build_back_link
      previous_path = course_back_path_for(back_step)

      raise "No path defined for back step: #{back_step}" if previous_path.nil?

      @back_link_path = previous_path
    end

    def course_back_path_for(page)
      case page
      when :school
        back_publish_provider_recruitment_cycle_courses_schools_path(path_params)
      when :study_site
        back_publish_provider_recruitment_cycle_courses_study_sites_path(path_params)
      when :modern_languages
        back_publish_provider_recruitment_cycle_courses_modern_languages_path(path_params)
      when :engineers_teach_physics
        back_publish_provider_recruitment_cycle_courses_engineers_teach_physics_path(path_params)
      else
        course_creation_path_for(page)
      end
    end

    def course_creation_path_for(page)
      case page
      when :courses_list
        publish_provider_recruitment_cycle_courses_path(@provider.provider_code, @provider.recruitment_cycle_year)
      when :level
        new_publish_provider_recruitment_cycle_courses_level_path(path_params)
      when :modern_languages
        new_publish_provider_recruitment_cycle_courses_modern_languages_path(path_params)
      when :engineers_teach_physics
        new_publish_provider_recruitment_cycle_courses_engineers_teach_physics_path(path_params)
      when :apprenticeship
        new_publish_provider_recruitment_cycle_courses_apprenticeship_path(path_params)
      when :school
        new_publish_provider_recruitment_cycle_courses_schools_path(path_params)
      when :study_site
        new_publish_provider_recruitment_cycle_courses_study_sites_path(path_params)
      when :entry_requirements
        new_publish_provider_recruitment_cycle_courses_entry_requirements_path(path_params)
      when :outcome
        new_publish_provider_recruitment_cycle_courses_outcome_path(path_params)
      when :full_or_part_time
        new_publish_provider_recruitment_cycle_courses_study_mode_path(path_params)
      when :applications_open
        new_publish_provider_recruitment_cycle_courses_applications_open_path(path_params)
      when :accredited_provider
        new_publish_provider_recruitment_cycle_courses_accredited_provider_path(path_params)
      when :can_sponsor_student_visa
        new_publish_provider_recruitment_cycle_courses_student_visa_sponsorship_path(path_params)
      when :can_sponsor_skilled_worker_visa
        new_publish_provider_recruitment_cycle_courses_skilled_worker_visa_sponsorship_path(path_params)
      when :start_date
        new_publish_provider_recruitment_cycle_courses_start_date_path(path_params)
      when :age_range
        new_publish_provider_recruitment_cycle_courses_age_range_path(path_params)
      when :subjects
        new_publish_provider_recruitment_cycle_courses_subjects_path(path_params)
      when :funding_type
        new_publish_provider_recruitment_cycle_courses_funding_type_path(path_params)
      when :confirmation
        confirmation_publish_provider_recruitment_cycle_courses_path(path_params)
      end
    end

    def tda_path_params
      path_params.merge(
        course: path_params[:course].merge({ funding_type: 'apprenticeship', study_mode: 'full_time' })
      )
    end

    def go_to_confirmation_params
      params[:goto_confirmation] || params.dig(:course, :goto_confirmation)
    end
  end
end
