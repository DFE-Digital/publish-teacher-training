# frozen_string_literal: true

module Filters
  class View < GovukComponent::Base
    attr_accessor :filters, :filter_label, :filter_actions

    def initialize(filters:, filter_label:, filter_actions: nil)
      @filters = filters
      @filter_actions = filter_actions
      @filter_label = filter_label
    end

    def tags_for_filter(filter, value)
      [{ title: title_html(filter, value), remove_link: remove_select_tag_link(filter) }]
    end

    def checked?(filters, filter, value)
      filters && filters[filter]&.include?(value)
    end

    def label_for(attribute, value)
      I18n.t("components.filter.users.#{attribute.pluralize}.#{value}")
    end

  private

    def providers_list?
      filter_label == t("components.filter.providers.provider_search")
    end

    def course_search?(filter)
      filter == "course_search"
    end

    def title_html(filter, value)
      tag.span("Remove ", class: "govuk-visually-hidden") + value + tag.span(" #{filter.humanize.downcase} filter", class: "govuk-visually-hidden")
    end

    def remove_select_tag_link(filter)
      new_filters = filters.reject { |f| f == filter }
      new_filters.to_query.blank? ? nil : "?" + new_filters.to_query
    end
  end
end

