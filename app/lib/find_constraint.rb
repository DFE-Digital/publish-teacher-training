# frozen_string_literal: true

class FindConstraint
  def matches?(request)
    Settings.find_temp_url&.include?(request.host) || request.subdomain =~ /\Afind2-pr-\d+\z/
  end
end
