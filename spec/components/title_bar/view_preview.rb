# frozen_string_literal: true

module TitleBar
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(title: title, provider: provider_code))
    end

  private

    def title
      "BAT School"
    end

    def provider_code
      "1BJ"
    end
  end
end
