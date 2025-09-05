# frozen_string_literal: true

module Filters
  class UserAttributes < ViewComponent::Base
    attr_accessor :filters

    def initialize(filters:)
      super
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
