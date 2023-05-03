# frozen_string_literal: true

class FindConstraint
  def matches?(request)
    Settings.find_url&.include?(request.host) || request.host.include?('find-pr') || request.host.include?('ptt-review')
  end
end
