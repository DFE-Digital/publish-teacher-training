# frozen_string_literal: true

class AreAnyALevelsRequiredStore < DfE::Wizard::Store
  delegate :course, to: :wizard

  def save
    updated_attributes = { a_level_requirements: }
    updated_attributes[:a_level_subject_requirements] = [] unless a_level_requirements?

    course.update!(updated_attributes)
  end

  def a_level_requirements?
    current_step.answer == 'yes'
  end
  alias a_level_requirements a_level_requirements?
end
