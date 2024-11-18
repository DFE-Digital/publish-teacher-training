# frozen_string_literal: true

Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

  constraints(APIConstraint.new) do
    get '/', to: redirect('/docs/')
  end

  constraints(FindConstraint.new) do
    draw(:find)
  end

  constraints(PublishConstraint.new) do
    draw(:publish)
    draw(:support)
    draw(:api)
  end

  direct :publish_support_view_component_previews, path_only: true do
    Rails.application.config.view_component.preview_route
  end
end
