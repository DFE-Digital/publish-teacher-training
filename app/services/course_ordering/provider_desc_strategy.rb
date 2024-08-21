# frozen_string_literal: true

module CourseOrdering
  class ProviderDescStrategy < BaseStrategy
    def order(scope)
      scope.descending_provider_canonical_order
    end
  end
end
