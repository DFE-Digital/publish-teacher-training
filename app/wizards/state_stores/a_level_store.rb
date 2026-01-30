module StateStores
  class ALevelStore
    include DfE::Wizard::StateStore

    def another_a_level_needed?
      add_another_a_level == "yes"
    end
  end
end
