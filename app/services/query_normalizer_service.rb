class QueryNormalizerService
  include ApiService

  def initialize(query:)
    @query = query
  end

  def call
    return "" if query.blank?

    CGI.unescape(query).downcase.gsub(/[^0-9a-z]/i, "")
  end

private

  attr_reader :query
end
