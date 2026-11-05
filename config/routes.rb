# frozen_string_literal: true

Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

  # Routes for a BaseWizard inside a resource block:
  #   resources :users do
  #     concerns :base_wizard, controller: "add_user_wizards"
  #   end
  # gives new_<resource>, and GET/PATCH wizard_<resources> at
  # <resources>/wizard/:state_key/:step.
  concern :base_wizard do |options|
    wizard_controller = options.fetch(:controller)

    new do
      get :new, to: "#{wizard_controller}#new"
    end

    collection do
      get "wizard/:state_key/:step", to: "#{wizard_controller}#show", as: :wizard
      patch "wizard/:state_key/:step", to: "#{wizard_controller}#update"
    end
  end

  # Drawn outside the host constraints: the response varies by host, but the
  # route must answer on every one of them.
  get "/robots.txt", to: "robots#show", format: false

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
