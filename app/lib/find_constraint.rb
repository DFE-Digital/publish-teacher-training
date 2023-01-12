# frozen_string_literal: true

class FindConstraint
  def matches?(request)
    Settings.find_temp_url&.include?(request.host) || request.host.include?("find2-pr")
  end
end
