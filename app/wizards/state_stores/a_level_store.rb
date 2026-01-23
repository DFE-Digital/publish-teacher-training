module StateStores
  class ALevelStore
    include DfE::Wizard::StateStore

    def subjects
      repository.record.a_level_subject_requirements
    end

    def pending_a_level
      case repository.record.accept_pending_a_level
      when TrueClass then "yes"
      when FalseClass then "no"
      end
    end

    def equivalent_a_level
      case repository.record.accept_a_level_equivalency
      when TrueClass then "yes"
      when FalseClass then "no"
      end
    end

    def another_a_level_needed?
      add_another_a_level == "yes"
    end
  end
end
