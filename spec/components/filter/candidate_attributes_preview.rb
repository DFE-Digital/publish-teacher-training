# frozen_string_literal: true

module Filters
  class CandidateAttributesPreview < ViewComponent::Preview
    def show_filter_attributes
      render(Filters::CandidateAttributes::View.new(filters: { text_search: "bob@gmail.com" }))
    end
  end
end
