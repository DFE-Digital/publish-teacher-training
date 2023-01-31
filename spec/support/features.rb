# frozen_string_literal: true

RSpec.configure do |config|
  config.include FeatureHelpers::Authentication, type: :feature
  config.include FeatureHelpers::NewCourseParam, type: :feature
  config.include FeatureHelpers::GovukComponents, type: :feature
  config.include FeatureHelpers::CourseSteps, type: :feature
  config.include FeatureHelpers::PageWithQuery, type: :feature
  config.include DfESignInUserHelper, type: :feature
  config.include FeatureHelpers::PageObject::Support, :support_features
  config.include FeatureHelpers::PageObject::Publish, :publish_features
  config.include FeatureHelpers::PageObject::Find, :find_features
  config.include FeatureHelpers::PageObject::Auth, :auth_features
end
