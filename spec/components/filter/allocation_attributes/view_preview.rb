# frozen_string_literal: true

module Filters
  module AllocationAttributes
    class ViewPreview < ViewComponent::Preview
      def show_allocation_filter_attributes
        render(Filters::AllocationAttributes::View.new(filters: { text_search: "Every Day, Once A Day, Give Yourself A Present" }))
      end
    end
  end
end
