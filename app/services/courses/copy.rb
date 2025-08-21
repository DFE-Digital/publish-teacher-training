# frozen_string_literal: true

module Courses
  class Copy
    GCSE_FIELDS = [
      ["Accept pending GCSE", "accept_pending_gcse", "accept-pending-gcse-true"],
      ["Accept GCSE equivalency", "accept_gcse_equivalency", "accept-gcse-equivalency-true"],
      ["Accept English GCSE equivalency", "accept_english_gcse_equivalency", "accept-english-gcse-equivalency-english"],
      ["Accept Maths GCSE equivalency", "accept_maths_gcse_equivalency", "accept-maths-gcse-equivalency-maths"],
      ["Additional GCSE equivalencies", "additional_gcse_equivalencies", "additional-gcse-equivalencies"],
    ].freeze

    SUBJECT_REQUIREMENTS_FIELDS = [
      ["Additional degree subject requirements", "additional_degree_subject_requirements"],
      ["Degree subject requirements", "degree_subject_requirements"],
    ].freeze

    ABOUT_THIS_COURSE_FIELDS = [
      ["About this course", "about_course"],
    ].freeze

    SCHOOL_PLACEMENT_FIELDS = [
      "What you will do on school placements", "placement_school_activities"
    ].freeze

    V2_SCHOOL_PLACEMENT_FIELDS = [
      ["What you will do on school placements", "placement_school_activities"],
      ["Support and mentorship", "support_and_mentorship"],
    ].freeze

    INTERVIEW_PROCESS_FIELDS = [
      ["Interview process", "interview_process"],
    ].freeze

    V2_INTERVIEW_PROCESS_FIELDS = [
      ["Interview process", "interview_process"],
      ["Interview location", "interview_location"],
    ].freeze

    SCHOOL_PLACEMENTS_FIELDS_V1 = [
      ["How placements work", "how_school_placements_work"],
    ].freeze

    FEES_FINANCIAL_SUPPORT_FIELDS = [
      ["Fees and financial support", "fee_details"],
    ].freeze

    V2_WHERE_YOU_WILL_TRAIN_FIELDS = [
      ["How do you decide which schools to place trainees in?", "placement_selection_criteria"],
      ["How much time will they spend in each school?", "duration_per_school"],
      ["Where will theoretical training take place?", "theoretical_training_location"],
      ["How much time will they spend in theoretical training?", "theoretical_training_duration"],
    ].freeze

    V2_FEES_AND_FINANCIAL_SUPPORT_FIELDS = [
      ["Fee for UK citizens", "fee_uk_eu"],
      ["Fee for non-UK citizens", "fee_international"],
      ["When are the fees due?", "fee_schedule"],
      ["Are there any additional fees or costs?", "additional_fees"],
      ["Does your organisation offer any financial support?", "financial_support"],
    ].freeze

    FEES_FIELDS = [
      ["Fee for UK students", "fee_uk_eu"],
      ["Fee for international students", "fee_international"],
    ].freeze

    SALARY_FIELDS = [
      ["Salary details", "salary_details"],
    ].freeze

    WHAT_YOU_WILL_STUDY_FIELDS = [
      ["Theoretical training activities", "theoretical_training_activities"],
      ["Assessment methods", "assessment_methods"],
    ].freeze

    # TODO: This is to be utilised when we add these to a course form
    VISA_FIELDS = [
      ["Can sponsor skilled worker visa", "can_sponsor_skilled_worker_visa"],
      ["Can sponsor student visa", "can_sponsor_student_visa"],
    ].freeze

    def self.get_present_fields_in_source_course(fields, source_course, course)
      fields.filter_map do |name, field|
        source_value = source_course.enrichment_attribute(field)
        next if source_value.blank?

        enrichment_to_update = course.enrichments.most_recent&.first || course.course.enrichments.find_or_initialize_draft
        enrichment_to_update.assign_attributes(field => source_value)

        [name, field, enrichment_to_update]
      end
    end

    def self.get_boolean_fields(fields, source_course, course)
      fields.select do |_name, field|
        source_value = source_course[field]
        course[field] = source_value if source_value.present?
      end
    end
  end
end
