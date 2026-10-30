# frozen_string_literal: true

class HeaderComponentPreview < ViewComponent::Preview
  def default
    render HeaderComponent.new(service_name: "Service Name")
  end

  def with_service_navigation
    render HeaderComponent.new(service_name: "Find and Publish support console") do |header|
      header.with_navigation_item("Providers", "/")
      header.with_navigation_item("Users", "/")
    end
  end

  def publish_signed_in
    render HeaderComponent.new(
      service_name: I18n.t("service_name.publish"),
      service_url: "/publish",
    ) do |header|
      header.with_navigation_item("Courses", "/courses")
      header.with_navigation_item("Schools", "/schools")
      header.with_account_options do
        "Sign out"
      end
    end
  end
end
