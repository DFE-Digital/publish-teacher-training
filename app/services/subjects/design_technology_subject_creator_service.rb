# frozen_string_literal: true

module Subjects
  class DesignTechnologySubjectCreatorService
    def initialize(subject_area: SubjectArea, design_technology_subject: DesignTechnologySubject, subjects_cache: SubjectsCache.new)
      @subject_area = subject_area
      @design_technology_subject = design_technology_subject
      @subjects_cache = subjects_cache
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
        { subject_name: "Product design", subject_code: "DTP" },
        { subject_name: "Textiles", subject_code: "DTT" },
      ]

      design_technology_subjects.each do |subject|
        @design_technology_subject.find_or_create_by!(
          subject_name: subject[:subject_name],
          subject_code: subject[:subject_code],
        )
      end

      @subjects_cache.expire_cache
    end
  end
end
