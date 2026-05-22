# frozen_string_literal: true

Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

  constraints host: Settings.api_hosts do
    draw(:external_api)
  end

  # The internal API is shared by the Find and Publish services. Draw it once
  # (rather than once per host) so its routes have unique names and can be
  # referenced via route helpers.
  constraints host: Settings.find_hosts + Settings.publish_hosts do
    draw(:internal_api)
  end

  constraints host: Settings.find_hosts do
    draw(:find)
  end

  constraints host: Settings.publish_hosts do
    draw(:publish)
    draw(:support)
  end
end
