# frozen_string_literal: true

class ALevelsWizard < DfE::Wizard::Base
  steps do
    [
      {
        are_any_alevels_required_for_this_course: ALevelSteps::AreAnyALevelsRequiredForThisCourse,
        what_alevel_is_required: ALevelSteps::WhatALevelIsRequired
      }
    ]
  end
end
