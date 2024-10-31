# frozen_string_literal: true

# PublishConstraint requires the server domain matches the request host to match routes
# Settings.base_url&.include?(request.host)
RSpec.configure do |config|
  config.before namespace: :publish, type: :request do
    host! URI(Settings.base_url).host
  end
end
