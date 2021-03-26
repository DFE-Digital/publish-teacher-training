# frozen_string_literal: true

module NavigationBar
  class ViewPreview < ViewComponent::Preview
    def default
      render NavigationBar::View.new(items: items, current_path: current_path)
    end

    def with_a_user_signed_in
      render NavigationBar::View.new(items: items, current_path: current_path, current_user: { first_name: "Ted" })
    end

  private

    def items
      [
        { name: "Home", url: "root_path" },
        { name: "Trainee records", url: "trainees_path", current: false },
      ]
    end

    def current_path
      "root_path"
    end
  end
end
