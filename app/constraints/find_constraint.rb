# frozen_string_literal: true

class FindConstraint
  REVIEW_HOST_REGEX = /https:\/\/find-review-.*\.test\.teacherservices\.cloud/

  def matches?(request)
    request.host.match?(REVIEW_HOST_REGEX) || Settings.find_hosts.include?(request.host)
  end
end
