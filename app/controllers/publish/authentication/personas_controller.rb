# frozen_string_literal: true

module Publish
  module Authentication
    class PersonasController < ApplicationController
      include Unauthenticated

      layout "application"

      def index; end
    end
  end
end
