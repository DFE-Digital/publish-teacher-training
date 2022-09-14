# frozen_string_literal: true

module CaptionText
  class ViewPreview < ViewComponent::Preview
    def default
      render(CaptionText::View.new(text: "Enter some random text here"))
    end
  end
end
