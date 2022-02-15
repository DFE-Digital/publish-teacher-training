module Publish
  module CourseBasicDetailConcern
    extend ActiveSupport::Concern

    included do
      decorates_assigned :course
      before_action :build_new_course, :build_provider, only: %i[back new continue confirmation]
      before_action :build_previous_course_creation_params, only: %i[new continue confirmation]
      before_action :build_meta_course_creation_params, only: %i[new continue]
      before_action :build_back_link, only: %i[new back continue]
      before_action :build_course, only: %i[edit update]
    end

    def back; end

    def new
      authorize(@provider, :can_create_course?)
    end

    def edit; end

    def update
      @errors = errors
      return render :edit if @errors.present?

      if @course.update(course_params)
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
      add_custom_age_range_into_params if params.dig("course", "age_range_in_years") == "other"
      provider = RecruitmentCycle.find_by(year: params[:recruitment_cycle_year]).providers.find_by(provider_code: params[:provider_code])

      @course = Course.new(
        provider: provider, **course_attributes,
      )
    end

    def course_attributes
      course_attributes = course_params.to_unsafe_hash.except(:sites_ids)
      course_attributes["subjects"] = subjects_from_ids if params.dig("course", "subjects").present?
      course_attributes["sites"] = sites_from_ids if params.dig("course", "sites_ids").present?
      course_attributes
    end

    def subjects_from_ids
      params.dig("course", "subjects")&.map do |subject_id|
        Subject.find(subject_id)
      end
    end

    def sites_from_ids
      params.dig("course", "sites_ids")&.map do |site_id|
        Site.find(site_id)
      end
    end

    def add_custom_age_range_into_params
      params["course"]["age_range_in_years"] = "#{age_from_param}_to_#{age_to_param}"
    end

    def errors
      @course.valid?(:new)
      @course.remove_carat_from_error_messages

      @course.errors.messages.select { |key, _message| error_keys.include?(key) }
    end

    def error_keys
      []
    end

    def build_provider
      @provider = RecruitmentCycle.find_by(year: params[:recruitment_cycle_year]).providers.find_by(provider_code: params[:provider_code])
    end

    def build_course
      @course = Course
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first
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
            :language_ids,
          )
          .permit(
            :page,
            :about_course,
            :course_length,
            :course_length_other_length,
            :fee_details,
            :fee_international,
            :fee_uk_eu,
            :financial_support,
            :how_school_placements_work,
            :interview_process,
            :other_requirements,
            :personal_qualities,
            :salary_details,
            :required_qualifications,
            :qualification, # qualification is actually "outcome"
            :maths,
            :english,
            :science,
            :funding_type,
            :level,
            :is_send,
            :program_type,
            :study_mode,
            :applications_open_from,
            :start_date,
            :age_range_in_years,
            :master_subject_id,
            :subordinate_subject_id,
            :funding_type,
            :accredited_body_code,
            sites_ids: [],
            subjects: [],
          )
      else
        ActionController::Parameters.new({}).permit(:course)
      end
    end

    def build_previous_course_creation_params
      @course_creation_params = course_params
    end

    def build_meta_course_creation_params
      @meta_course_creation_params = params.slice(:goto_confirmation)
    end

    def continue_step
      if params[:goto_confirmation] && current_step != :subjects
        :confirmation
      else
        CourseCreationStepService.new.execute(current_step: current_step, course: @course)[:next]
      end
    end

    def next_step
      continue_path = course_creation_path_for(continue_step)

      if continue_path.nil?
        raise "No path defined for continue step: #{continue_path}"
      end

      continue_path
    end

    def path_params
      path_params = { course: course_params }
      path_params[:goto_confirmation] = params[:goto_confirmation] if params[:goto_confirmation]
      path_params
    end

    def back_step
      if params[:goto_confirmation]
        if current_step == :modern_languages
          :subjects
        else
          :confirmation
        end
      else
        CourseCreationStepService.new.execute(current_step: current_step, course: @course)[:previous]
      end
    end

    def build_back_link
      previous_path = course_back_path_for(back_step)

      if previous_path.nil?
        raise "No path defined for back step: #{back_step}"
      end

      @back_link_path = previous_path
    end

    def course_back_path_for(page)
      case page
      when :location
        back_publish_provider_recruitment_cycle_courses_locations_path(path_params)
      when :modern_languages
        back_publish_provider_recruitment_cycle_courses_modern_languages_path(path_params)
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
      when :apprenticeship
        new_publish_provider_recruitment_cycle_courses_apprenticeship_path(path_params)
      when :location
        new_publish_provider_recruitment_cycle_courses_locations_path(path_params)
      when :entry_requirements
        new_publish_provider_recruitment_cycle_courses_entry_requirements_path(path_params)
      when :outcome
        new_publish_provider_recruitment_cycle_courses_outcome_path(path_params)
      when :full_or_part_time
        new_publish_provider_recruitment_cycle_courses_study_mode_path(path_params)
      when :applications_open
        new_publish_provider_recruitment_cycle_courses_applications_open_path(path_params)
      when :accredited_body
        new_publish_provider_recruitment_cycle_courses_accredited_body_path(path_params)
      when :start_date
        new_publish_provider_recruitment_cycle_courses_start_date_path(path_params)
      when :age_range
        new_publish_provider_recruitment_cycle_courses_age_range_path(path_params)
      when :subjects
        new_publish_provider_recruitment_cycle_courses_subjects_path(path_params)
      when :fee_or_salary
        new_publish_provider_recruitment_cycle_courses_fee_or_salary_path(path_params)
      when :confirmation
        confirmation_publish_provider_recruitment_cycle_courses_path(path_params)
      end
    end
  end
end
