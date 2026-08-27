module Support::BannersHelper
  def displayed_on_text(banner)
    banner.displayed_on.map(&:to_s).map { |displayed_on| t("support.banners.index.displayed_on.#{displayed_on}") }.to_sentence.presence || t("support.banners.index.displayed_on.none")
  end
end
