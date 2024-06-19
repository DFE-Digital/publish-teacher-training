# frozen_string_literal: true

class ALevelsWizardStore < DfE::Wizard::Store
  delegate :valid_step?, :current_step_name, :course, to: :wizard

  def save
    return false unless valid_step?

    if current_step_name == :are_any_a_levels_required_for_this_course && current_step.answer == 'no'
      course.update!(
        a_level_requirements: false
      )
    end

    true
  end
end