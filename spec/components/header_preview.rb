# frozen_string_literal: true

class HeaderPreview < ViewComponent::Preview
  def with_custom_service_name
    render(Header.new(service_name: "Hello"))
  end

  def with_our_service_name
    render(Header.new(service_name: I18n.t("service_name.publish")))
  end

  def with_a_signed_in_user
    render(Header.new(service_name: I18n.t("service_name.publish"), current_user: mock_user))
  end

private

  def mock_items
    [{ name: "Link", url: "https://www.google.com" }]
  end

  def mock_user
    OpenStruct.new(admin?: false, associated_with_accredited_provider?: true)
  end
end
