# frozen_string_literal: true

module Sandbox
  # Turns a course's attributes from the public Publish API into attributes
  # for Course and CourseEnrichment. Pure: it doesn't touch the database.
  class CourseAttributesMapper
    COURSE_FIELDS = %w[
      name
      level
      study_mode
      program_type
      degree_grade
      degree_type
      degree_subject_requirements
      is_send
      campaign_name
      application_status
      accept_pending_gcse
      accept_gcse_equivalency
      accept_english_gcse_equivalency
      accept_maths_gcse_equivalency
      accept_science_gcse_equivalency
      additional_gcse_equivalencies
      can_sponsor_skilled_worker_visa
      can_sponsor_student_visa
      visa_sponsorship_application_deadline_at
      school_experience_required
      school_experience_required_content
    ].freeze

    ENRICHMENT_FIELDS = %w[
      about_course
      additional_fees
      assessment_methods
      course_length
      duration_per_school
      fee_details
      fee_international
      fee_schedule
      financial_support
      how_school_placements_work
      interview_process
      interview_location
      other_requirements
      personal_qualities
      placement_school_activities
      placement_selection_criteria
      salary_details
      support_and_mentorship
      theoretical_training_activities
      theoretical_training_duration
      theoretical_training_location
    ].freeze

    # The inverse of WithQualifications#qualifications, keyed on the sorted list.
    QUALIFICATIONS = {
      %w[qts] => "qts",
      %w[pgce qts] => "pgce_with_qts",
      %w[pgde qts] => "pgde_with_qts",
      %w[pgce] => "pgce",
      %w[pgde] => "pgde",
      %w[qts undergraduate_degree] => "undergraduate_degree_with_qts",
    }.freeze

    def initialize(attributes)
      @attributes = attributes
    end

    def course_code
      @attributes["code"]
    end

    def subject_codes
      Array(@attributes["subject_codes"])
    end

    # qualification= also sets profpost_flag (WithQualifications).
    def course_attributes
      @attributes.slice(*COURSE_FIELDS).merge(
        "qualification" => qualification,
        "funding" => @attributes["funding_type"],
        "age_range_in_years" => age_range_in_years,
        "start_date" => Date.strptime(@attributes["start_date"], "%B %Y"),
        "accredited_provider_code" => @attributes["accredited_body_code"],
        "additional_degree_subject_requirements" => @attributes["degree_subject_requirements"].present?,
        "english" => @attributes["required_qualifications_english"],
        "maths" => @attributes["required_qualifications_maths"],
        "science" => @attributes["required_qualifications_science"],
      )
    end

    def enrichment_attributes
      @attributes.slice(*ENRICHMENT_FIELDS).merge("fee_uk_eu" => @attributes["fee_domestic"])
    end

  private

    def qualification
      QUALIFICATIONS.fetch(Array(@attributes["qualifications"]).map(&:to_s).sort)
    end

    def age_range_in_years
      return if @attributes["age_minimum"].blank? || @attributes["age_maximum"].blank?

      "#{@attributes['age_minimum']}_to_#{@attributes['age_maximum']}"
    end
  end
end
