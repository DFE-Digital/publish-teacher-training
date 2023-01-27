# frozen_string_literal: true

class CaptionTextPreview < ViewComponent::Preview
  def default
    render(CaptionText.new(text: 'Enter some random text here'))
  end
end
