# frozen_string_literal: true

module Find
  module Header
    class View < ApplicationComponent
      attr_reader :service_name

      include ActiveModel

      def initialize(service_name:, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @service_name = service_name
      end

      def environment_header_class
        "app-header--#{Settings.environment.name}"
      end
    end
  end
end
