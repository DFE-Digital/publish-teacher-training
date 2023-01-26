# frozen_string_literal: true

class NavigationBarPreview < ViewComponent::Preview
  def default
    render NavigationBar.new(items:, current_path:)
  end

  def with_a_user_signed_in
    render NavigationBar.new(items:, current_path:, current_user: { first_name: "Ted" })
  end

private

  def items
    [
      { name: "Home", url: "root_path" },
      { name: "Providers", url: "#", current: false }
    ]
  end

  def current_path
    "root_path"
  end
end
