module ValidQualification
  extend ActiveSupport::Concern

  included do
    def valid_qualification?(course)
      if course.level == :further_education
        course.qualifications.any? && course.qualifications.exclude?(:qts)
      else
        course.qualifications.include?(:qts)
      end
    end
  end
end
