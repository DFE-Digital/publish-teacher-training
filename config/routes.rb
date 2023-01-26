# frozen_string_literal: true

Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

  constraints(APIConstraint.new) do
    get '/', to: redirect('/docs/')
  end

  constraints(host: /www2\./) do
    match '/(*path)' => redirect { |_, req| "#{Settings.base_url}#{req.fullpath}" }, via: %i[get post put]
  end

  if %w[development test review qa].include?(Rails.env)
    constraints(FindConstraint.new) do
      draw(:find)
    end
  end

  constraints(PublishConstraint.new) do
    draw(:publish)
    draw(:support)
    draw(:api)
  end
end
