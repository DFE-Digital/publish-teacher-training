# frozen_string_literal: true

module CourseOrdering
  class ProviderAscStrategy < BaseStrategy
    def order(scope)
      scope.ascending_provider_canonical_order
    end
  end
end
