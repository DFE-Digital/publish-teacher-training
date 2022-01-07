# frozen_string_literal: true

module Filters
  module ProviderAttributes
    class ViewPreview < ViewComponent::Preview
      def show_filter_attributes
        render(Filters::ProviderAttributes::View.new(filters: { provider_search: "My Log Does Not Judge", course_search: "" }))
      end
    end
  end
end
