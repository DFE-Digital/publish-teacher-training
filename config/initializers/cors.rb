# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  origin_urls = [Settings.find_url, Settings.publish_url].compact_blank

  allow do
    origins origin_urls
    resource "*", headers: :any, methods: %i[get post patch put]
  end
end
