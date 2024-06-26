# frozen_string_literal: true

module ALevelSteps
  class AddALevelToAList < DfE::Wizard::Step
    attr_accessor :add_another_a_level
    attr_writer :subjects

    MAXIMUM_NUMBER_OF_A_LEVEL_SUBJECTS = 4

    validates :add_another_a_level, presence: true, unless: :maximum_number_of_a_level_subjects?

    def self.permitted_params
      [
        :add_another_a_level,
        { subjects: %i[uuid subject minimum_grade_required other_subject] }
      ]
    end

    def maximum_number_of_a_level_subjects?
      subjects.size >= MAXIMUM_NUMBER_OF_A_LEVEL_SUBJECTS
    end

    def subjects
      Array(@subjects)
    end

    def next_step
      if add_another_a_level == 'yes'
        :what_a_level_is_required
      else
        :consider_pending_a_level
      end
    end
  end
end
