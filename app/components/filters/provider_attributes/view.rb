module Filters
  module ProviderAttributes
    class View < GovukComponent::Base
      attr_accessor :filters

      def initialize(filters:)
        @filters = filters
      end
    end
  end
end
