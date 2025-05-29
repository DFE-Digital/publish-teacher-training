# frozen_string_literal: true

module Publish
  module Authentication
    class PersonasController < ApplicationController
      layout "application"

      skip_before_action :authenticate
      skip_after_action :verify_authorized

      def index; end
    end
  end
end
