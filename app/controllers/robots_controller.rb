# frozen_string_literal: true

# Served from a route rather than public/, because a static file is host-blind:
# Find, Publish, the API and the test environments share one public directory.
#
# Not ApplicationController: enforce_basic_auth returns 401 wherever basic auth
# is enabled, and Google reads any 4xx on robots.txt as "no restrictions".
# rubocop:disable Rails/ApplicationController
class RobotsController < ActionController::Base
  # rubocop:enable Rails/ApplicationController

  def show
    render template: robots_template, formats: :text, layout: false, content_type: "text/plain"
  end

private

  def robots_template
    indexable? ? "robots/allow" : "robots/disallow"
  end

  # Not Rails.env: staging, sandbox, QA and review all run RAILS_ENV=production.
  def indexable?
    Settings.environment.name == "production" &&
      request.host == URI.parse(Settings.find_url).host
  end
end
