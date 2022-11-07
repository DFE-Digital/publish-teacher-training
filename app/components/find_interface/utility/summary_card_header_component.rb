module FindInterface
  module Utility
    class SummaryCardHeaderComponent < ViewComponent::Base
      def initialize(title:, heading_level: 2, anchor: nil)
        super
        @title = title
        @heading_level = heading_level
        @anchor = anchor
      end
    end
  end
end
