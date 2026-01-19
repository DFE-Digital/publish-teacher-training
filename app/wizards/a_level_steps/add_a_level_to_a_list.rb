# frozen_string_literal: true

module ALevelSteps
  class AddALevelToAList
    include DfE::Wizard::Step
    attr_writer :subjects

    MAXIMUM_NUMBER_OF_A_LEVEL_SUBJECTS = 4

    attribute :add_another_a_level, :string

    # validates :add_another_a_level, presence: true, unless: :maximum_number_of_a_level_subjects?

    def self.permitted_params
      [
        :add_another_a_level,
        { subjects: %i[uuid subject minimum_grade_required other_subject] },
      ]
    end

    def maximum_number_of_a_level_subjects?
      subjects.size >= MAXIMUM_NUMBER_OF_A_LEVEL_SUBJECTS
    end

    def subjects
      wizard.state_store.subjects
    end
  end
end
