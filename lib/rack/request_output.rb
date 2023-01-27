# frozen_string_literal: true

module Rack
  class RequestOutput
    def initialize(app)
      @app = app
    end

    def call(env)
      Rails.logger.info { "API HIT => #{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['REQUEST_URI']}" }

      @app.call(env)
    end
  end
end
