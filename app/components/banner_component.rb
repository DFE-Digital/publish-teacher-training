# frozen_string_literal: true

class BannerComponent < ViewComponent::Base
  GOVUK_LINK_CLASS = 'class="govuk-link"'
  NOTIFICATION_BANNER_LINK_CLASS = 'class="govuk-notification-banner__link"'
  TITLE_ID_PREFIX = "govuk-notification-banner-title"

  def initialize(banner:)
    super()

    @banner = banner
  end

private

  attr_reader :banner

  def body
    helpers.markdown(banner.body).gsub(GOVUK_LINK_CLASS, NOTIFICATION_BANNER_LINK_CLASS).html_safe
  end

  def title_id
    "#{TITLE_ID_PREFIX}-#{banner.id}"
  end
end
