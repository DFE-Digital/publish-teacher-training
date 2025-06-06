# frozen_string_literal: true

module Courses
  class CreationService
    include ServicePattern

    attr_reader :course_params, :provider, :next_available_course_code

    def initialize(course_params:, provider:, next_available_course_code: false)
      @course_params = course_params
      @provider = provider
      @next_available_course_code = next_available_course_code
    end

    def call
      build_new_course
    end

  private

    def new_course
      @new_course ||= provider.courses.new
    end

    def build_new_course
      course = provider.courses.new
      course.assign_attributes(course_attributes.except(:subjects_ids, :study_mode, :visa_sponsorship_application_deadline_required))

      if course_attributes[:master_subject_id].blank? && course_attributes[:subordinate_subject_id].present?
        course.errors.add(:subjects, :course_creation)
      elsif subject_ids.present? || course_attributes[:level] == "further_education"
        AssignSubjectsService.call(course:, subject_ids:)
      end

      update_study_mode(course)
      update_sites(course)
      update_study_sites(course)

      if assign_accrediting_provider_by_single_partner?(course)
        course.accrediting_provider = course.provider.accredited_partners.first
      end

      course.course_code = provider.next_available_course_code if next_available_course_code

      Publish::Courses::AssignTdaAttributesService.new(course).call if course.undergraduate_degree_with_qts?
      Courses::AssignProgramTypeService.new.execute(course.funding, course)
      clean_up_visa_properties(course)
      Courses::AssignVisaSponsorshipApplicationDeadlineService.execute(course_params, course)
      course.valid?(:new) if course.errors.blank?

      course.remove_carat_from_error_messages

      course
    end

    def clean_up_visa_properties(course)
      if course.fee?
        course.can_sponsor_skilled_worker_visa = false
      else
        course.can_sponsor_student_visa = false
      end
    end

    def course_attributes
      @course_attributes ||= course_params.to_h.symbolize_keys.slice(*permitted_new_course_attributes)
    end

    def permitted_new_course_attributes
      @permitted_new_course_attributes ||= CoursePolicy.new(nil, new_course).permitted_new_course_attributes
    end

    def sites
      @sites ||= provider.sites.find(site_ids.compact_blank)
    end

    def study_sites
      @study_sites ||= provider.study_sites.find(study_site_ids.compact_blank)
    end

    def subject_ids
      @subject_ids ||= course_params["subjects_ids"]
    end

    def site_ids
      @site_ids ||= course_params["sites_ids"]
    end

    def study_mode
      @study_mode ||= if course_params["study_mode"].nil?
                        nil
                      else
                        Array(course_params["study_mode"])&.flatten&.compact&.uniq
                      end
    end

    def study_site_ids
      @study_site_ids ||= course_params["study_sites_ids"]
    end

    def update_study_mode(course)
      return if study_mode.nil?

      if study_mode.empty?
        course.errors.add(
          :study_mode,
          I18n.t("activemodel.errors.models.publish/course_study_mode_form.attributes.study_mode.blank"),
        )
      else
        course.study_mode = study_mode.sort.join("_or_")
      end
    end

    def update_sites(course)
      return if site_ids.nil?

      course.sites = sites if site_ids.any?

      course.errors.add(:sites, message: "Select at least one school") if site_ids.empty?
    end

    def update_study_sites(course)
      return if study_site_ids.nil?

      course.study_sites = study_sites if study_site_ids.any?

      course.errors.add(:study_sites, message: "Select at least one study site") if study_site_ids.empty?
    end

    def assign_accrediting_provider_by_single_partner?(course)
      !course.provider.accredited? && course.provider.accredited_partners.one?
    end
  end
end
