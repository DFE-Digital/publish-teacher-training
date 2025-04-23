# frozen_string_literal: true

class PublishConstraint
  REVIEW_HOST_REGEX = /https:\/\/publish-review-.*\.test\.teacherservices\.cloud/

  def matches?(request)
    request.host.match?(REVIEW_HOST_REGEX) || Settings.publish_hosts.include?(request.host)
  end
end
