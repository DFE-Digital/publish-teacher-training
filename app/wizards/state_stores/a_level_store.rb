module StateStores
  class ALevelStore
    include DfE::Wizard::StateStore

    def subjects
      repository.record.a_level_subject_requirements
    end

    def another_a_level_needed?
      add_another_a_level == "yes"
    end

    # def needs_permission_to_work_or_study?
    #   # nationalities is an attribute from the Steps::Nationality
    #   !Array(nationalities).intersect?(%w[british irish])
    # end
    #
    # def right_to_work_or_study?
    #   # right_to_work_or_study is an attribute from the Steps::RightToWorkOrStudy
    #   right_to_work_or_study == 'yes'
    # end

    # def save
    #   return false unless valid_step?
    #
    #   WhatALevelIsRequiredStore.new(wizard).save if current_step_name == :what_a_level_is_required
    #   ConsiderPendingALevelStore.new(wizard).save if current_step_name == :consider_pending_a_level
    #   ALevelEquivalenciesStore.new(wizard).save if current_step_name == :a_level_equivalencies
    #
    #   true
    # end
    #
    # def destroy
    #   RemoveALevelSubjectConfirmationStore.new(wizard).destroy if current_step_name == :remove_a_level_subject_confirmation
    # end
  end
end
