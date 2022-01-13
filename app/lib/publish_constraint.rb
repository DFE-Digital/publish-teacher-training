# frozen_string_literal: true

class PublishConstraint
  def matches?(request)
    Settings.base_url.include?(request.host)
  end
end
