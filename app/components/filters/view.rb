# frozen_string_literal: true

module Filters
  class View < ViewComponent::Base
    attr_accessor :filters, :filter_model

    def initialize(filters:, filter_model:)
      @filters = filters
      @filter_model = filter_model
      super
    end

  private

    def tags_for_filter(filter, value)
      [value].flatten.map do |v|
        { title: title_html(filter, v), remove_link: remove_select_tag_link(filter) }
      end
    end

    def filter_attributes
      "::Filters::#{filter_model}Attributes::View".constantize.new(filters:)
    end

    def filter_label(filter)
      t("components.filter.#{filter_model.to_s.downcase.pluralize}.#{filter}")
    end

    def title_html(filter, value)
      tag.span("Remove ", class: "govuk-visually-hidden") + value + tag.span(" #{filter.humanize.downcase} filter", class: "govuk-visually-hidden")
    end

    def remove_select_tag_link(filter)
      new_filters = filters.reject { |f| f == filter }
      new_filters.to_query.blank? ? nil : "?#{new_filters.to_query}"
    end

    def reload_path
      send("support_#{filter_model.to_s.downcase.pluralize}_path".to_sym)
    end
  end
end
