# frozen_string_literal: true

module CourseFilters
  class ProviderNameFilter < BaseFilter
    def call(scope)
      scope.with_provider_name(filter[:'provider.provider_name'])
    end

    def add_filter?
      filter[:'provider.provider_name'].present?
    end
  end
end
