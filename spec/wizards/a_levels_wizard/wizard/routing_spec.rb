# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ALevelsWizard#routing", type: :wizard do
  include_context "a_levels_wizard"

  context "from what_a_level_is_required" do
    let(:current_step) { :what_a_level_is_required }
    let(:a_level_subject_requirements) { [] }

    it "has no previous step (root)" do
      options = { course_code: "XYZ", recruitment_cycle_year: 2025, provider_code: "123" }
      helpers = Rails.application.routes.url_helpers

      path =  wizard.route_strategy.routes[:course_edit].call(wizard, options, helpers)
      path_options = { code: "XYZ", recruitment_cycle_year: 2025, provider_code: "123" }
      expect(path).to match(helpers.publish_provider_recruitment_cycle_course_path(path_options))
    end
  end
end
