module StateStores
  class ALevelStore
    include DfE::Wizard::StateStore

    def subjects
      repository.record.a_level_subject_requirements
    end

    def any_a_levels?
      subjects.length.positive?
    end

    def another_a_level_needed?
      add_another_a_level == "yes"
    end
  end
end
