# frozen_string_literal: true

class ApiConstraint
  def matches?(request)
    Settings.publish_api_url.include?(request.host)
  end
end
