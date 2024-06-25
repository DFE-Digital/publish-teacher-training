# frozen_string_literal: true

module ALevelSteps
  class AddALevelToAList < DfE::Wizard::Step
    attr_accessor :subjects, :add_another_a_level

    validates :add_another_a_level, presence: true

    def self.permitted_params
      { subjects: %i[subject minimum_grade_required other_subject] }
    end
  end
end
