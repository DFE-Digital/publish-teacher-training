# frozen_string_literal: true

module Subjects
  class SubjectAreaCreatorService
    def initialize(subject_area: SubjectArea)
      @subject_area = subject_area
    end

    def execute
      @subject_area.find_or_create_by!(typename: 'PrimarySubject', name: 'Primary')
      @subject_area.find_or_create_by!(typename: 'SecondarySubject', name: 'Secondary')
      @subject_area.find_or_create_by!(typename: 'ModernLanguagesSubject', name: 'Secondary: Modern languages')
      @subject_area.find_or_create_by!(typename: 'FurtherEducationSubject', name: 'Further education')
      @subject_area.find_or_create_by!(typename: 'DiscontinuedSubject', name: 'Discontinued')
    end
  end
end
