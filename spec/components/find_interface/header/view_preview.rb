# frozen_string_literal: true

module FindInterface::Header
  class ViewPreview < ViewComponent::Preview
    def with_custom_service_name
      render(Header::View.new(service_name: "Hello"))
    end

    def with_our_service_name
      render(Header::View.new(service_name: I18n.t("service_name.find")))
    end
  end
end
