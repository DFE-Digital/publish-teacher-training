# frozen_string_literal: true

require_relative "feature_helpers/authentication"
require_relative "feature_helpers/course_steps"
require_relative "dfe_sign_in_user_helper"

RSpec.configure do |config|
  config.include FeatureHelpers::Authentication, type: :feature
  config.include FeatureHelpers::NewCourseParam, type: :feature
  config.include FeatureHelpers::GovukComponents, type: :feature
  config.include FeatureHelpers::PageObjectMethodCreator, type: :feature
  config.include FeatureHelpers::CourseSteps, type: :feature
  config.include DfESignInUserHelper, type: :feature
end
