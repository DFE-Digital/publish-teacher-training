# frozen_string_literal: true

module UtmHelper
  # Appends UTM tracking parameters to a URL, preserving any existing query
  # string. Works for both internally generated route URLs and external links.
  def with_utm(url, params:, content:)
    uri = URI.parse(url)
    utm = params.merge(utm_content: content).to_query
    uri.query = [uri.query.presence, utm].compact.join("&")
    uri.to_s
  end
end
