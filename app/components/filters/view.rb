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

    def filter_attributes
      "::Filters::#{filter_model}Attributes::View".constantize.new(filters:)
    end

    def filter_label(filter)
      t("components.filter.#{filter_model.to_s.downcase.pluralize}.#{filter}")
    end

    def title_html(filter, value)
      value = value.keys.first if value.respond_to?(:keys)
      tag.span("Remove ", class: "govuk-visually-hidden") + value + tag.span(" #{filter.humanize.downcase} filter", class: "govuk-visually-hidden")
    end

    ### Tags are links you can click to remove the search property and reload the page
    def tags_for_filter(filter, value)
      if value.respond_to?(:keys)
        value = value.keys
        Array(value).map do |v|
          { title: title_html(filter, v), remove_link: remove_select_tag_link({ filter => v }) }
        end
      else
        Array(value).map do |v|
          { title: title_html(filter, v), remove_link: remove_select_tag_link(filter) }
        end
      end
    end

    def remove_select_tag_link(filter)
      new_filters = filters.deep_dup

      if filter.respond_to?(:keys)
        new_filters[filter.keys.first].delete(filter.values.first)
      else
        new_filters.reject! { |f| f == filter }
      end
      new_filters.to_query.blank? ? nil : "?#{new_filters.to_query}"
    end

    def reload_path
      send(:"support_recruitment_cycle_#{filter_model.to_s.downcase.pluralize}_path")
    end
  end
end
