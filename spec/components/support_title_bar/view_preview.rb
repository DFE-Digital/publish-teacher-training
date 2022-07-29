# frozen_string_literal: true

module SupportTitleBar
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new)
    end
  end
end
