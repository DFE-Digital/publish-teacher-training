# frozen_string_literal: true

module Filters
  module AllocationAttributes
    class ViewPreview < ViewComponent::Preview
      def show_allocation_filter_attributes
        render(Filters::AllocationAttributes::View.new(filters: nil))
      end
    end
  end
end
