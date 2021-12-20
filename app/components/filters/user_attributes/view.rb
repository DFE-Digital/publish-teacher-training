module Filters
  module UserAttributes
    class View < GovukComponent::Base
      attr_accessor :filters, :filter_label

      def initialize(filters:, filter_label:)
        @filters = filters
        @filter_label = filter_label
      end

    private

      def checked?(filters, filter, value)
        filters && filters[filter]&.include?(value)
      end

      def label_for(attribute, value)
        I18n.t("components.filter.users.#{attribute.pluralize}.#{value}")
      end
    end
  end
end
