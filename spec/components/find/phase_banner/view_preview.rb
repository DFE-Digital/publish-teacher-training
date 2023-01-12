# frozen_string_literal: true

module Find
  module PhaseBanner
    class ViewPreview < ViewComponent::Preview
      def default
        render(Find::PhaseBanner::View.new)
      end

      def with_no_border
        render(Find::PhaseBanner::View.new(no_border: true))
      end
    end
  end
end
