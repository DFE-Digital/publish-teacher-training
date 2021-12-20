# frozen_string_literal: true

module Filters
  class View < GovukComponent::Base
    attr_accessor :filters, :filter_actions, :filter_model

    def initialize(filters:, filter_model:, filter_actions: nil)
      @filters = filters
      @filter_actions = filter_actions
      @filter_model = filter_model
    end

  private

    def tags_for_filter(filter, value)
      # Sometimes we can have multiple filter values/tags, ie for box-checking filters.
      # A lean solution to conflicting value vs values of filters is to treat all
      # as values, hence the flatten.map
      [value].flatten.map do |v|
        { title: title_html(filter, v), remove_link: remove_select_tag_link(filter) }
      end
    end

    def filter_attributes
      "::Filters::#{filter_model}Attributes::View".constantize.new(filters: filters)
    end

    def filter_label(filter)
      t("components.filter.#{filter_model.to_s.downcase.pluralize}.#{filter}")
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

