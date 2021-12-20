# frozen_string_literal: true

require_relative "feature_helpers/authentication"
require_relative "feature_helpers/support_pages"
require_relative "feature_helpers/publish_interface_pages"
require_relative "dfe_sign_in_user_helper"

RSpec.configure do |config|
  config.include FeatureHelpers::Authentication, type: :feature
  config.include FeatureHelpers::GovukComponents, type: :feature
  config.include FeatureHelpers::SupportPages, type: :feature
  config.include FeatureHelpers::PublishInterfacePages, type: :feature
  config.include DfESignInUserHelper, type: :feature
end
