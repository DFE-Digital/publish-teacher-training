# frozen_string_literal: true

class FindConstraint
  def matches?(request)
    request.host.include?('find')
  end
end
