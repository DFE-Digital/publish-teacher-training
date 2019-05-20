module Subjects
  class UCASSubjectToDFESubjectStaticMapping
    def initialize(included_ucas_subjects, resulting_dfe_subject)
      @included_ucas_subjects = included_ucas_subjects
      @resulting_dfe_subject = resulting_dfe_subject
    end

    def applicable_to?(ucas_subjects_to_map)
      (ucas_subjects_to_map & @included_ucas_subjects).any?
    end

    def to_dfe_subject
      @resulting_dfe_subject
    end
  end
end
