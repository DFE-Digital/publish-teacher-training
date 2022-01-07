module Filters
  module AllocationAttributes
    class View < ViewComponent::Base
      attr_accessor :filters

      def initialize(filters:)
        @filters = filters
        super
      end
    end
  end
end
