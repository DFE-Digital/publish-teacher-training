# frozen_string_literal: true

module ALevelSteps
  class AddALevelToAList < DfE::Wizard::Step
    attr_accessor :subjects, :add_another_a_level

    MAXIMUM_NUMBER_OF_A_LEVEL_SUBJECTS = 4

    validates :add_another_a_level, presence: true

    def self.permitted_params
      [
        :add_another_a_level,
        { subjects: %i[uuid subject minimum_grade_required other_subject] }
      ]
    end

    def maximum_number_of_a_level_subjects?
      subjects.size >= MAXIMUM_NUMBER_OF_A_LEVEL_SUBJECTS
    end

    def next_step
      if add_another_a_level == 'yes'
        :what_a_level_is_required
      else
        :pending_a_level
      end
    end
  end
end
