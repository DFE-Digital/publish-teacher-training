# frozen_string_literal: true

RSpec.configure do |config|
  config.include FeatureHelpers::Authentication, type: :feature
  config.include FeatureHelpers::NewCourseParam, type: :feature
  config.include FeatureHelpers::GovukComponents, type: :feature
  config.include FeatureHelpers::CourseSteps, type: :feature
  config.include FeatureHelpers::PageWithQuery, type: :feature
  config.include DfESignInUserHelper, type: :feature
  config.include FeatureHelpers::PageObject::Support, :with_publish_constraint
  config.include FeatureHelpers::PageObject::Publish, :with_publish_constraint
  config.include FeatureHelpers::PageObject::Find, :with_find_constraint
  config.include FeatureHelpers::PageObject::Auth, %i[with_publish_constraint with_find_constraint]
end
