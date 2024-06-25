# frozen_string_literal: true

module ALevelSteps
  class AddALevelToAList < DfE::Wizard::Step
    attr_accessor :subjects, :add_another_a_level

    validates :add_another_a_level, presence: true

    def self.permitted_params
      [
        :add_another_a_level,
        { subjects: %i[subject minimum_grade_required other_subject] }
      ]
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
