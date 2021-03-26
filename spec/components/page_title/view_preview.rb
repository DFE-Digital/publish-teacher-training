# frozen_string_literal: true

require "govuk/components"

class PageTitle::ViewPreview < ViewComponent::Preview
  def default_heading
    render(PageTitle::View.new(title: "sign_in.index"))
  end

  def heading_with_error
    render(PageTitle::View.new(title: "sign_in.index", has_errors: true))
  end
end
