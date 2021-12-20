module Filters
  module UserAttributes
    class View < GovukComponent::Base
      attr_accessor :filters

      def initialize(filters:)
        @filters = filters
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
