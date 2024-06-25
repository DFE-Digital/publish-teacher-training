# frozen_string_literal: true

module ALevelSteps
  class AreAnyALevelsRequiredForThisCourse < DfE::Wizard::Step
    delegate :course, :exit_path, to: :wizard
    attr_accessor :answer

    validates :answer, presence: true

    def self.permitted_params
      [:answer]
    end

    def previous_step
      :first_step
    end

    def next_step
      return :exit if answer == 'no'

      if answer == 'yes' && course.a_level_subject_requirements.present?
        :add_a_level_to_a_list
      else
        :what_a_level_is_required
      end
    end
  end
end
