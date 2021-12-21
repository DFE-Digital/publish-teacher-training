# frozen_string_literal: true

module Filters
  module UserAttributes
    class ViewPreview < ViewComponent::Preview
      def show_filter_attributes
        render(Filters::UserAttributes::View.new(filters: nil))
      end
    end
  end
end
