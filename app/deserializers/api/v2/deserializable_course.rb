module API
  module V2
    class DeserializableCourse < JSONAPI::Deserializable::Resource
      COURSE_ATTRIBUTES = %i[
        about_course
        course_length
        fee_details
        fee_international
        fee_uk_eu
        financial_support
        how_school_placements_work
        interview_process
        other_requirements
        personal_qualities
        salary_details
        required_qualifications
        course_code
        name
        study_mode
        qualifications
        english
        maths
        science
        qualification
        age_range_in_years
        start_date
        applications_open_from
        study_mode
        is_send
        accredited_body_code
        funding_type
        level
        degree_grade
        additional_degree_subject_requirements
        degree_subject_requirements
        accept_pending_gcse
        accept_gcse_equivalency
        accept_english_gcse_equivalency
        accept_maths_gcse_equivalency
        accept_science_gcse_equivalency
        additional_gcse_equivalencies
      ].freeze

      attributes(*COURSE_ATTRIBUTES)

      has_many :sites
      has_many :subjects

      def reverse_mapping
        declared_attributes = DeserializableCourse.attr_blocks.keys
        declared_attributes
          .to_h { |key| [key.to_sym, "/data/attributes/#{key}"] }
      end
    end
  end
end
