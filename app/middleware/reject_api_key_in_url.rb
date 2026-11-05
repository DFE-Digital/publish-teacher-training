# frozen_string_literal: true

class RejectAPIKeyInUrl
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless key_in_url?(env)

    [401, { "content-type" => "application/json; charset=utf-8", "www-authenticate" => "Bearer" }, [error_body]]
  end

private

  def key_in_url?(env)
    env.values_at(Rack::PATH_INFO, Rack::QUERY_STRING).any? { |part| APIKeySecret.present_in?(part) }
  end

  def error_body
    { errors: [{ status: 401, title: I18n.t("errors.401.title"), detail: I18n.t("errors.401.detail") }] }.to_json
  end
end
