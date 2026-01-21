module StateStores
  class ALevelStore
    include DfE::Wizard::StateStore

    def subjects
      repository.record.a_level_subject_requirements
    end

    def pending_a_level
      repository.record.accept_pending_a_level ? "no" : "yes"
    end

    def equivalent_a_level
      repository.record.accept_a_level_equivalency ? "no" : "yes"
    end

    def another_a_level_needed?
      add_another_a_level == "yes"
    end
  end
end
