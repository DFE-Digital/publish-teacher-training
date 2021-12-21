# frozen_string_literal: true

module Filters
  module UserAttributes
    class ViewPreview < ViewComponent::Preview
      def show_filter_attributes
        render(Filters::UserAttributes::View.new(filters: { text_search: "Diane! I'm holding in my hand a small box of chocolate bunnies" }))
      end
    end
  end
end
