module Publish
  module Schools
    class NotificationBannerComponent < ViewComponent::Base
      def initialize(recruitment_cycle:, provider:)
        @recruitment_cycle = recruitment_cycle
        @provider = provider

        super
      end

      def render?
        @recruitment_cycle.rollover_period_2026?
      end
    end
  end
end
