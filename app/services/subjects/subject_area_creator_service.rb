module Subjects
  class SubjectAreaCreatorService
    def initialize(subject_area: SubjectArea)
      @subject_area = subject_area
    end

    def execute
      @subject_area.find_or_create_by!(typename: "PrimarySubject", name: "Primary")
      @subject_area.find_or_create_by!(typename: "SecondarySubject", name: "Secondary")
      @subject_area.find_or_create_by!(typename: "ModernLanguagesSubject", name: "Secondary: Modern Languages")
      @subject_area.find_or_create_by!(typename: "FurtherEducationSubject", name: "Further Education")
      @subject_area.find_or_create_by!(typename: "DiscontinuedSubject", name: "Discontinued")
    end
  end
end
