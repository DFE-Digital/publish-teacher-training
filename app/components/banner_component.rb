# frozen_string_literal: true

class BannerComponent < ViewComponent::Base
  GOVUK_LINK_CLASS = 'class="govuk-link"'
  NOTIFICATION_BANNER_LINK_CLASS = 'class="govuk-notification-banner__link"'
  LEADING_PARAGRAPH = %r{\A\s*<p class="govuk-body">}
  NOTIFICATION_BANNER_HEADING = '<p class="govuk-notification-banner__heading">'
  TITLE_ID_PREFIX = "govuk-notification-banner-title"

  def initialize(banner:)
    super()

    @banner = banner
  end

private

  attr_reader :banner

  def body
    banner_links.sub(LEADING_PARAGRAPH, NOTIFICATION_BANNER_HEADING).html_safe
  end

  def banner_links
    helpers.markdown(banner.body).gsub(GOVUK_LINK_CLASS, NOTIFICATION_BANNER_LINK_CLASS)
  end

  def title_id
    "#{TITLE_ID_PREFIX}-#{banner.id}"
  end
end
