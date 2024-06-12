# frozen_string_literal: true

module Publish
  class ALevelsWizard < DfE::Wizard::Base
    attr_accessor :provider_code, :recruitment_cycle_year, :code

    steps do
      [
        {
          are_any_alevels_required_for_this_course: ALevelSteps::AreAnyALevelsRequiredForThisCourse,
          what_alevel_is_required: ALevelSteps::WhatALevelIsRequired
        }
      ]
    end
  end
end
