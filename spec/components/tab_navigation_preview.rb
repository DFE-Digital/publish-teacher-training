# frozen_string_literal: true

class TabNavigationPreview < ViewComponent::Preview
  def default
    render(TabNavigation.new(items:))
  end

  def with_current_item_highlited
    with_current = items.prepend(
      { name: 'Training details', url: mock_link, current: true }
    )

    render(TabNavigation.new(items: with_current))
  end

private

  def items
    [
      { name: 'Personal details', url: mock_link },
      { name: 'Timeline', url: mock_link }
    ]
  end

  def mock_link
    'https://www.gov.uk'
  end
end
