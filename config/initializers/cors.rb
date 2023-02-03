# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Settings.base_url, Settings.find_url
    resource '*', headers: :any, methods: %i[get post patch put]
  end
end
