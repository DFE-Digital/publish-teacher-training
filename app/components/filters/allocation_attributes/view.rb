module Filters
  module AllocationAttributes
    class View < GovukComponent::Base
      attr_accessor :filters

      def initialize(filters:)
        @filters = filters
      end
    end
  end
end
