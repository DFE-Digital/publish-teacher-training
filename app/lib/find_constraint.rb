# frozen_string_literal: true

class FindConstraint
  def matches?(request)
    Settings.find_temp_url&.include?(request.host)
  end
end
