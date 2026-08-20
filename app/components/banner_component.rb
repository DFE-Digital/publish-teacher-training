# frozen_string_literal: true

class BannerComponent < ViewComponent::Base
  DEFAULT_TITLE_HEADING_LEVEL = 2

  def initialize(banner:)
    super()

    @banner = banner
  end

private

  attr_reader :banner

  def title_heading_level
    banner.title_heading_level || DEFAULT_TITLE_HEADING_LEVEL
  end
end
