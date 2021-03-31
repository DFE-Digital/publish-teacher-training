# frozen_string_literal: true

module Header
  class ViewPreview < ViewComponent::Preview
    def with_custom_service_name
      render(Header::View.new(service_name: "Hello"))
    end

    def with_our_service_name
      render(Header::View.new(service_name: I18n.t("service_name")))
    end

    def with_items
      render(Header::View.new(service_name: I18n.t("service_name"), items: mock_items))
    end

  private

    def mock_items
      [{ name: "Link", url: "https://www.google.com" }]
    end
  end
end
