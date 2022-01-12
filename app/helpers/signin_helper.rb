# frozen_string_literal: true

module SigninHelper
  def from_old_publish?
    request.referer&.include?(Settings.publish_url) && FeatureService.enabled?(:display_migration_signin)
  end
end
