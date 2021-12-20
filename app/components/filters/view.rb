# frozen_string_literal: true

module Filters
  class View < GovukComponent::Base
    attr_accessor :filters, :filter_label, :filter_actions, :filter_model

    def initialize(filters:, filter_label:, filter_model:, filter_actions: nil)
      @filters = filters
      @filter_actions = filter_actions
      @filter_label = filter_label
      @filter_model = filter_model
    end

    def tags_for_filter(filter, value)
      [{ title: title_html(filter, value), remove_link: remove_select_tag_link(filter) }]
    end

  private

    def filter_attributes
      "::Filters::#{filter_model}Attributes::View".constantize.new(filters: filters, filter_label: filter_label)
    end

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

