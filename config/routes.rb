Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

  scope via: :all do
    match "/404", to: "errors#not_found"
    match "/500", to: "errors#internal_server_error"
    match "/403", to: "errors#forbidden"
  end

  constraints(APIConstraint.new) do
    get "/", to: redirect("/docs/")
  end

  constraints(host: /www2\./) do
    match "/(*path)" => redirect { |_, req| "#{Settings.base_url}#{req.fullpath}" }, via: %i[get post put]
  end

  if %w[development test review qa].include?(Rails.env)
    draw(:find)
  end

  draw(:publish)
  draw(:support)
  draw(:api)
end
