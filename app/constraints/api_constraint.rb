# frozen_string_literal: true

class APIConstraint
  REVIEW_HOST_REGEX = /https:\/\/.*-review-.*\.test\.teacherservices\.cloud/

  def matches?(request)
    request.host.match?(REVIEW_HOST_REGEX) || Settings.api_hosts.include?(request.host)
  end
end
