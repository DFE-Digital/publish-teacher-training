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
      # TODO School data remodel removal - remove site_status writes # rubocop:disable Style/CommentAnnotation
      # once add-course creation only writes Course::School.
      update_sites(course)
      update_schools(course)
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

    def school_uuids
      @school_uuids ||= Array(course_params["school_uuids"]).compact_blank
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
      return unless school_selection_submitted?

      if selected_school_identifiers.empty?
        course.errors.add(:sites, message: "Select at least one school")
        return
      end

      return add_school_uuid_resolution_error(course) if school_uuid_resolution_error?

      selected_sites = selected_school_records.select { |school| school.is_a?(Site) }
      course.sites = selected_sites if selected_sites.any?
    end

    # Dual-writes the selected schools to the new Course::School model,
    # building the records in memory so they persist atomically with the
    # course on save and are visible to CoursePublishableSchoolsPresence-
    # Validator's :new-context read.
    def update_schools(course)
      return unless school_selection_submitted?
      return if selected_school_identifiers.empty?
      return if school_uuid_resolution_error?

      selected_school_records.each do |school|
        case school
        when Site
          build_course_school_from_site(course:, site: school)
        when Provider::School
          build_course_school(course:, provider_school: school)
        end
      end
    end

    def school_selection_submitted?
      course_params.key?("school_uuids") || course_params.key?("sites_ids")
    end

    def selected_school_identifiers
      @selected_school_identifiers ||= if course_params.key?("school_uuids")
                                         school_uuids
                                       else
                                         Array(site_ids).compact_blank
                                       end
    end

    def selected_school_records
      return @selected_school_records if defined?(@selected_school_records)

      @selected_school_records = if course_params.key?("school_uuids")
                                   course_school_identity.school_records_for(school_uuids:)
                                 else
                                   sites
                                 end
    rescue ArgumentError => e
      @school_uuid_resolution_error = e
      @selected_school_records = []
    end

    def school_uuid_resolution_error?
      selected_school_records
      @school_uuid_resolution_error.present?
    end

    def add_school_uuid_resolution_error(course)
      Rails.logger.warn(
        "[CourseSchools] invalid school UUIDs for provider=#{provider.id}: #{@school_uuid_resolution_error.message}",
      )
      course.errors.add(:sites, message: "Select at least one school")
    end

    def build_course_school_from_site(course:, site:)
      gias_school = gias_schools_by_urn[site.urn]
      return unless gias_school

      provider_school = provider_schools_by_uuid[site.uuid.to_s]

      unless provider_school
        Rails.logger.warn(
          "[CourseSchools] skipped course_school build - no provider_school for " \
          "provider=#{provider.id} site_uuid=#{site.uuid} gias_school=#{gias_school.id}",
        )
        return
      end

      build_course_school(course:, provider_school:)
    end

    def build_course_school(course:, provider_school:)
      course.schools.build(gias_school: provider_school.gias_school, provider_school:)
    end

    def gias_schools_by_urn
      @gias_schools_by_urn ||= GiasSchool.available
        .where(urn: selected_sites.map(&:urn).compact_blank)
        .index_by(&:urn)
    end

    def selected_sites
      @selected_sites ||= selected_school_records.select { |school| school.is_a?(Site) && school.school? }
    end

    def provider_schools_by_uuid
      @provider_schools_by_uuid ||= provider.schools
        .where(uuid: selected_sites.map { |site| site.uuid.to_s })
        .index_by { |school| school.uuid.to_s }
    end

    def course_school_identity
      @course_school_identity ||= CourseSchools::Identity.new(provider:)
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
