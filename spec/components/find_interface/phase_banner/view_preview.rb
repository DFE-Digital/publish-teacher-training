# frozen_string_literal: true

module FindInterface
  module PhaseBanner
    class ViewPreview < ViewComponent::Preview
      def default
        render(FindInterface::PhaseBanner::View.new)
      end

      def with_no_border
        render(FindInterface::PhaseBanner::View.new(no_border: true))
      end
    end
  end
end
