# frozen_string_literal: true

require_relative "feature_helpers/authentication"
require_relative "feature_helpers/course_steps"
require_relative "feature_helpers/support_pages"
require_relative "feature_helpers/publish_pages"
require_relative "dfe_sign_in_user_helper"

RSpec.configure do |config|
  config.include FeatureHelpers::Authentication, type: :feature
  config.include FeatureHelpers::NewCourseParam, type: :feature
  config.include FeatureHelpers::GovukComponents, type: :feature
  config.include FeatureHelpers::SupportPages, type: :feature
  config.include FeatureHelpers::PublishPages, type: :feature
  config.include FeatureHelpers::CourseSteps, type: :feature
  config.include DfESignInUserHelper, type: :feature

  # This is required as a workaround for failing tests when the `can_edit_current_and_next_cycles` feature flag is active
  config.around do |example|
    can_edit_current_and_next_cycles = example.metadata[:can_edit_current_and_next_cycles]

    if can_edit_current_and_next_cycles == false
      old_value = Settings.features.rollover.can_edit_current_and_next_cycles
      Settings.features.rollover.can_edit_current_and_next_cycles = false
      Rails.application.reload_routes!

      example.run

      Settings.features.rollover.can_edit_current_and_next_cycles = old_value
      Rails.application.reload_routes!
    else
      example.run
    end
  end
end
