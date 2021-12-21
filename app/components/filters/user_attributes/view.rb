module Filters
  module UserAttributes
    class View < ViewComponent::Base
      attr_accessor :filters

      def initialize(filters:)
        @filters = filters
        super
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
