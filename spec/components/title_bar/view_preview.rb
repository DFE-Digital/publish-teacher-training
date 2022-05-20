# frozen_string_literal: true

module TitleBar
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(title: title))
    end

  private

    def title
      "BAT School"
    end
  end
end
