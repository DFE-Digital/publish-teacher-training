# frozen_string_literal: true

Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

  constraints(APIConstraint.new) do
    get "/", to: redirect("/docs/")
  end

  constraints(FindConstraint.new) do
    draw(:find)
    draw(:find_api)
  end

  constraints(PublishConstraint.new) do
    draw(:publish)
    draw(:support)
    draw(:publish_api)
  end
end
