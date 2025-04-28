# frozen_string_literal: true

Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

  constraints host: Settings.api_hosts do
    draw(:external_api)
  end

  constraints host: Settings.find_hosts do
    draw(:internal_api)
    draw(:find)
  end

  constraints host: Settings.publish_hosts do
    draw(:internal_api)
    draw(:publish)
    draw(:support)
  end
end
