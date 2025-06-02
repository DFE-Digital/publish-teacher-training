# frozen_string_literal: true

module Publish
  module Authentication
    class PersonasController < ApplicationController
      layout "application"

      skip_before_action :authenticate
      skip_after_action :verify_authorized
      skip_before_action :authorize_provider

      def index; end
    end
  end
end
