# frozen_string_literal: true

require 'govuk/components'

class PageTitlePreview < ViewComponent::Preview
  def default_heading
    render(PageTitle.new(title: 'sign_in.index'))
  end

  def heading_with_error
    render(PageTitle.new(title: 'sign_in.index', has_errors: true))
  end
end
