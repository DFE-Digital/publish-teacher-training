# frozen_string_literal: true

RSpec.configure do |config|
  config.include FeatureHelpers::Authentication, type: :system
  config.include FeatureHelpers::NewCourseParam, type: :system
  config.include FeatureHelpers::GovukComponents, type: :system
  config.include FeatureHelpers::CourseSteps, type: :system
  config.include FeatureHelpers::PageWithQuery, type: :system
  config.include DfESignInUserHelper, type: :system
  config.include FeatureHelpers::PageObject::Support, :support_features
  config.include FeatureHelpers::PageObject::Publish, :publish_features
  config.include FeatureHelpers::PageObject::Find, :find_features
  config.include FeatureHelpers::PageObject::Auth, :auth_features
end
