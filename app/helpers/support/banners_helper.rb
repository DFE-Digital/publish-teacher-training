module Support::BannersHelper
  def banner_status_tag(banner)
    status_colours = {
      draft: "grey",
      active: "green",
      scheduled: "yellow",
      expired: "red",
    }

    govuk_tag(
      text: t("support.banners.index.statuses.#{banner.status}"),
      colour: status_colours.fetch(banner.status),
    )
  end

  def displayed_on_text(banner)
    banner.displayed_on.map(&:to_s).map { |displayed_on| t("support.banners.index.displayed_on.#{displayed_on}") }.to_sentence.presence || t("support.banners.index.displayed_on.none")
  end
end
