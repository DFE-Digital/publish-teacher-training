# frozen_string_literal: true

class HeaderComponentPreview < ViewComponent::Preview
  def default
    render HeaderComponent.new(service_name: "Service Name")
  end

  def with_service_navigation
    render HeaderComponent.new(service_name: "Find and Publish support console") do |header|
      header.with_navigation_item("Home", "/")
      header.with_navigation_item("Home", "/")
    end
  end
end
