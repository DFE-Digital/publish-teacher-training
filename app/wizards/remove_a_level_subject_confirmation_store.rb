# frozen_string_literal: true

class RemoveALevelSubjectConfirmationStore < DfE::Wizard::Store
  delegate :course, to: :wizard
  delegate :uuid, to: :current_step

  def destroy
    return unless current_step.deletion_confirmed?

    a_level_subject_requirements = course.a_level_subject_requirements.reject { |req| req['uuid'] == uuid }

    if a_level_subject_requirements.present?
      course.update!(a_level_subject_requirements:)
    else
      course.update!(
        a_level_subject_requirements: [],
        accept_pending_a_level: nil,
        accept_a_level_equivalency: nil,
        additional_a_level_equivalencies: nil
      )
    end
  end
end
