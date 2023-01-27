# frozen_string_literal: true

module Find
  class FeedbackComponentPreview < ViewComponent::Preview
    def default
      render(FeedbackComponent.new(path: '/path', controller: 'results'))
    end
  end
end
