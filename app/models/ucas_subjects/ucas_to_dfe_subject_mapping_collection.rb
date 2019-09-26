module UCASSubjects
  class UCASToDFESubjectMappingCollection
    def initialize(config:)
      @mappings = init_subject_mappings(config)
    end

    def to_dfe_subjects(ucas_subjects:, course_title:)
      @mappings.
        select { |mapping| mapping.applicable_to?(ucas_subjects, course_title) }.
        collect(&:to_dfe_subject)
    end

  private

    def init_subject_mappings(config)
      config.map do |ucas_input_subjects, dfe_subject|
        UCASToDFESubjectMapping.new(ucas_input_subjects, dfe_subject)
      end
    end
  end
end
