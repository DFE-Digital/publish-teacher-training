module Support
  module BannersHelper
    TIME_SEGMENTS = { hour: 4, minute: 5 }.freeze
    TIME_READERS = { 4 => :hour, 5 => :min }.freeze

    def displayed_on_text(banner)
      banner.displayed_on.map(&:to_s).map { |displayed_on| t("support.banners.index.displayed_on.#{displayed_on}") }.to_sentence.presence || t("support.banners.index.displayed_on.none")
    end

    def banner_time_part(banner, attribute, index)
      value = banner.public_send(attribute)

      return if value.nil?
      return value.fetch(index) if value.respond_to?(:fetch)

      value.public_send(TIME_READERS.fetch(index))
    end
  end
end
