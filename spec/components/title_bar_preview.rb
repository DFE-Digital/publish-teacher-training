# frozen_string_literal: true

class TitleBarPreview < ViewComponent::Preview
  def default
    render(TitleBar.new(title:, provider: provider_code, current_user:))
  end

private

  def title
    'BAT School'
  end

  def provider_code
    '1BJ'
  end

  def current_user
    User.new(email: 'foo@live.com', first_name: 'foo', last_name: 'bar', admin: true)
  end
end
