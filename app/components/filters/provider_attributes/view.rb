module Filters
  module ProviderAttributes
    class View < GovukComponent::Base
      attr_accessor :filters, :filter_label

      def initialize(filters:, filter_label:)
        @filters = filters
        @filter_label = filter_label
      end
    end
  end
end
