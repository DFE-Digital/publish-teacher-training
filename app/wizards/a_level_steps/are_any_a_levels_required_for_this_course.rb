# frozen_string_literal: true

module ALevelSteps
  class AreAnyALevelsRequiredForThisCourse < DfE::Wizard::Step
    delegate :exit_path, to: :wizard
    attr_accessor :answer

    validates :answer, presence: true

    def self.permitted_params
      [:answer]
    end

    def previous_step
      :first_step
    end

    def next_step
      if answer == 'yes'
        :what_a_level_is_required
      elsif answer == 'no'
        :exit
      end
    end
  end
end
