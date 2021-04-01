# frozen_string_literal: true

module LayoutHelper
  # Enables inheriting from and extending another layout.
  # Adapted from the nestive gem: https://github.com/rwz/nestive/blob/master/lib/nestive/layout_helper.rb#L84
  def extends_layout(layout, &block)
    layout = layout.to_s
    layout = "layouts/#{layout}" unless layout.include?("/")
    view_flow.get(:layout).replace(capture(&block).to_s)

    render(template: layout)
  end
end
