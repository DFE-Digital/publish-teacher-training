# frozen_string_literal: true

module Filters
  class ProviderAttributesPreview < ViewComponent::Preview
    def show_filter_attributes
      render(Filters::ProviderAttributes::View.new(filters: { provider_search: "My Log Does Not Judge", course_search: "" }))
    end
  end
end
