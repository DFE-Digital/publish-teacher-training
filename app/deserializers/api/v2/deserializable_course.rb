module API
  module V2
    class DeserializableCourse < JSONAPI::Deserializable::Resource
      attributes :about_course,
                 :course_length,
                 :fee_details,
                 :fee_international,
                 :fee_uk_eu,
                 :financial_support,
                 :how_school_placements_work,
                 :interview_process,
                 :other_requirements,
                 :personal_qualities,
                 :qualifications,
                 :salary_details,
                 :course_code,
                 :name,
                 :study_mode

      has_many :sites

      attribute :required_qualifications do |value|
        { qualifications: value }
      end
    end
  end
end
