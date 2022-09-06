module Courses
  class Copy
    GCSE_FIELDS = [
      ["Accept pending GCSE", "accept_pending_gcse"],
      ["Accept GCSE equivalency", "accept_gcse_equivalency"],
      ["Accept English GCSE equivalency", "accept_english_gcse_equivalency"],
      ["Accept Maths GCSE equivalency", "accept_maths_gcse_equivalency"],
      ["Additional GCSE equivalencies", "additional_gcse_equivalencies"],
    ].freeze

    SUBJECT_REQUIREMENTS_FIELDS = [
      ["Additional degree subject requirements", "additional_degree_subject_requirements"],
      ["Degree subject requirements", "degree_subject_requirements"],
    ].freeze

    ABOUT_FIELDS = [
      ["About the course", "about_course"],
      ["Interview process", "interview_process"],
      ["How school placements work", "how_school_placements_work"],
    ].freeze

    FEES_FIELDS = [
      ["Course length", "course_length"],
      ["Fee for UK students", "fee_uk_eu"],
      ["Fee for international students", "fee_international"],
      ["Fee details", "fee_details"],
      ["Financial support", "financial_support"],
    ].freeze

    SALARY_FIELDS = [
      ["Course length", "course_length"],
      ["Salary details", "salary_details"],
    ].freeze

    POST_2022_CYCLE_REQUIREMENTS_FIELDS = [
      ["Personal qualities", "personal_qualities"],
      ["Other requirements", "other_requirements"],
    ].freeze

    PRE_2022_CYCLE_REQUIREMENTS_FIELDS = [
      ["Qualifications needed", "required_qualifications"],
      ["Personal qualities", "personal_qualities"],
      ["Other requirements", "other_requirements"],
    ].freeze

    # TODO: This is to be utilised when we add these to a course form
    VISA_FIELDS = [
      ["Can sponsor skilled worker visa", "can_sponsor_skilled_worker_visa"],
      ["Can sponsor student visa", "can_sponsor_student_visa"],
    ].freeze

    def self.get_present_fields_in_source_course(fields, source_course, course)
      fields.filter_map do |name, field|
        source_value = source_course.enrichments.last[field]
        if source_value.present?
          course.enrichments.last[field] = source_value
          [name, field]
        end
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
