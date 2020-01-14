module Courses
  class AssignableMasterSubjectService
    def initialize(
      primary_subject: PrimarySubject,
      secondary_subject: SecondarySubject,
      further_education_subject: FurtherEducationSubject
    )
      @primary_subject = primary_subject
      @secondary_subject = secondary_subject
      @further_education_subject = further_education_subject
    end

    def execute(course:)
      case course.level
      when "primary"
        @primary_subject.includes(:financial_incentive).all
      when "secondary"
        @secondary_subject.includes(:financial_incentive).all
      when "further_education"
        @further_education_subject.includes(:financial_incentive).all
      end
    end
  end
end
