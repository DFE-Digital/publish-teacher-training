# frozen_string_literal: true

module Subjects
  class DesignTechnologySubjectCreatorService
    def initialize(subject_area: SubjectArea, design_technology_subject: DesignTechnologySubject)
      @subject_area = subject_area
      @design_technology_subject = design_technology_subject
    end

    def execute
      @subject_area.find_or_create_by!(
        typename: "DesignTechnologySubject",
        name: "Secondary: Design and technology",
      )

      design_technology_subjects = [
        { subject_name: "Electronics", subject_code: "DTE" },
        { subject_name: "Engineering", subject_code: "DTEN" },
        { subject_name: "Food technology", subject_code: "DTF" },
        { subject_name: "Product technology", subject_code: "DTP" },
        { subject_name: "Textiles", subject_code: "DTT" },
      ]

      design_technology_subjects.each do |subject|
        @design_technology_subject.find_or_create_by!(
          subject_name: subject[:subject_name],
          subject_code: subject[:subject_code],
        )
      end
    end
  end
end
