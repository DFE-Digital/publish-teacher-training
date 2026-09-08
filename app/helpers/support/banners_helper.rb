module Support
  module BannersHelper
    TIME_SEGMENTS = { hour: 4, minute: 5 }.freeze
    TIME_READERS = { 4 => :hour, 5 => :min }.freeze

    def displayed_on_text(banner)
      banner.displayed_on.map(&:to_s).map { |displayed_on| t("support.banners.index.displayed_on.#{displayed_on}") }.to_sentence.presence || t("support.banners.index.displayed_on.none")
    end

    def banner_word_count_options(form, attribute, maximum)
      info_id = "#{banner_field_id(form, attribute)}-info"

      {
        class: "govuk-js-character-count",
        aria: { describedby: info_id },
        form_group: { class: "govuk-character-count", data: { module: "govuk-character-count", maxwords: maximum } },
        after_input: tag.span(
          t("support.banners.form.word_count", count: maximum),
          id: info_id,
          class: "govuk-hint govuk-character-count__message",
        ),
      }
    end

    def banner_field_id(form, attribute)
      suffix = form.object.errors[attribute].present? ? "field-error" : "field"

      [form.object_name, attribute, suffix].join("-").parameterize.tr("_", "-")
    end

    def banner_time_invalid?(banner, attribute)
      value = banner.public_send(attribute)

      value.is_a?(PotentialDateTime) && value.time_invalid?
    end

    def banner_time_part(banner, attribute, index)
      value = banner.public_send(attribute)

      return if value.nil?
      return value.fetch(index) if value.respond_to?(:fetch)

      value.public_send(TIME_READERS.fetch(index))
    end
  end
end
