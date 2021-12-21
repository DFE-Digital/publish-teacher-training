# frozen_string_literal: true

module Filters
  module ProviderAttributes
    class ViewPreview < ViewComponent::Preview
      def show_filter_attributes
        render(Filters::ProviderAttributes::View.new(filters: nil))
      end
    end
  end
end
