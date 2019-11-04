module Courses
  class AssignableSubjectService
    def initialize(
      primary_subject: PrimarySubject,
      secondary_subject: SecondarySubject,
      modern_language_subject: ModernLanguagesSubject,
      further_education_subject: FurtherEducationSubject,
      modern_languages_parent_subject: SecondarySubject.modern_languages
  )
      @primary_subject = primary_subject
      @secondary_subject = secondary_subject
      @modern_language_subject = modern_language_subject
      @further_education_subject = further_education_subject
      @modern_languages_parent_subject = modern_languages_parent_subject
    end

    def execute(course)
      case course.level
      when "primary"
        @primary_subject.all
      when "secondary"
        @secondary_subject.where.not(id: @modern_languages_parent_subject) + @modern_language_subject.all
      when "further_education"
        @further_education_subject.all
      end
    end
  end
end
