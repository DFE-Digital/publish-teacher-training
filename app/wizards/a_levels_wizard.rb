# frozen_string_literal: true

class ALevelsWizard < DfE::Wizard::Base
  attr_accessor :provider_code, :recruitment_cycle_year, :course_code

  steps do
    [
      {
        are_any_alevels_required_for_this_course: ALevelSteps::AreAnyALevelsRequiredForThisCourse,
        what_alevel_is_required: ALevelSteps::WhatALevelIsRequired
      }
    ]
  end

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
end
