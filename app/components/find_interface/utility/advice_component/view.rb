module FindInterface
  module Utility
    class AdviceComponent::View < ViewComponent::Base
      include ViewHelper

      attr_reader :title

      def initialize(title:)
        super
        @title = title
      end
    end
  end
end
