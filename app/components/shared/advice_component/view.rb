# frozen_string_literal: true

module Shared
  module AdviceComponent
    class View < ViewComponent::Base
      include ::ViewHelper

      attr_reader :title

      def initialize(title:)
        super
        @title = title
      end
    end
  end
end
