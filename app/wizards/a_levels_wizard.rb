# frozen_string_literal: true

class ALevelsWizard < DfE::Wizard::Base
  attr_accessor :provider, :course

  delegate :course_code, to: :course
  delegate :provider_code, :recruitment_cycle_year, to: :course
  delegate :destroy, to: :store

  steps do
    [
      { are_any_a_levels_required_for_this_course: ALevelSteps::AreAnyALevelsRequiredForThisCourse },
      { what_a_level_is_required: ALevelSteps::WhatALevelIsRequired },
      { add_a_level_to_a_list: ALevelSteps::AddALevelToAList },
      { remove_a_level_subject_confirmation: ALevelSteps::RemoveALevelSubjectConfirmation },
      { consider_pending_a_level: ALevelSteps::ConsiderPendingALevel },
      { a_level_equivalencies: ALevelSteps::ALevelEquivalencies }
    ]
  end

  store ALevelsWizardStore

  # Default argument passed to all the routing in this wizard
  # All course editing specific is done through the URL
  #
  # /publish/organisations/:provider_code/:recruitment_cycle_year/courses/:course_code
  #
  def default_path_arguments
    { provider_code:, recruitment_cycle_year:, course_code: }
  end

  # Definitions of Rails routes prefix namespace for A levels with default path arguments
  # above.
  #
  # Of one example is the first step to the second step:
  #
  # publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required
  #
  # publish_provider_recruitment_cycle_course - defined below
  # a_levels - ALevelSteps module
  # what_a_level_is_required - WhatALevelIsRequired step
  #
  def default_path_prefix
    'publish_provider_recruitment_cycle_course'
  end

  def exit_path
    url_helpers.publish_provider_recruitment_cycle_course_path(
      provider_code:,
      recruitment_cycle_year:,
      code: course_code
    )
  end

  def logger
    DfE::Wizard::Logger.new(Rails.logger, if: -> { Rails.env.development? })
  end
end
