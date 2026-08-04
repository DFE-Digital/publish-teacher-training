# frozen_string_literal: true

module Publish
  module Courses
    # The filters on the publish course list. Modelled on ::Courses::SearchForm
    # (the Find search form) but deliberately separate: none of that form's
    # subject, provider or location machinery applies here.
    #
    # Every group is a multi-select list of checkboxes, and each reader allows only
    # the values that group offers. That single choke point means an unrecognised
    # value in the query string reaches neither the SQL nor an active filter chip.
    #
    # Every group but start date offers a fixed list of options. Start date offers
    # the months the provider's courses start in, so narrowing that list narrows
    # the checkboxes, the allowed values and the chip labels together.
    class FilterForm < ApplicationForm
      Option = Data.define(:value, :label)

      # Also the order the groups appear in the panel and their chips in the
      # active filters.
      GROUPS = %i[status level funding qualification study_mode start_date].freeze

      STATUS_OPTIONS = %w[open closed draft rolled_over scheduled withdrawn].freeze
      LEVEL_OPTIONS = %w[primary secondary further_education].freeze
      FUNDING_OPTIONS = %w[fee salary apprenticeship].freeze
      QUALIFICATION_OPTIONS = %w[qts qts_with_pgce_or_pgde].freeze
      STUDY_MODE_OPTIONS = %w[full_time part_time].freeze

      STATIC_OPTIONS = {
        status: STATUS_OPTIONS,
        level: LEVEL_OPTIONS,
        funding: FUNDING_OPTIONS,
        qualification: QUALIFICATION_OPTIONS,
        study_mode: STUDY_MODE_OPTIONS,
      }.freeze

      GROUPS.each do |group|
        attribute group

        define_method(group) { Array(super()) & allowed_values_for(group) }
      end

      attr_reader :provider

      def initialize(provider:, **attributes)
        @provider = provider
        super(attributes)
      end

      # The selected values, ready to hand to Publish::Courses::Query.
      def filter_params
        GROUPS.index_with { |group| public_send(group) }.compact_blank
      end

      # How many options are selected in each group, for the "N selected" hint.
      # nil rather than 0 so the hint is simply absent when nothing is selected.
      def filter_counts
        GROUPS.index_with { |group| public_send(group).presence&.count }
      end

      def any_filters?
        filter_params.any?
      end

      def options_for(group)
        group == :start_date ? start_date_options : static_options_for(group)
      end

      # Chips, in group order, each removing only its own value.
      def active_filters
        @active_filters ||= GROUPS.flat_map { |group| active_filters_for(group) }
      end

    private

      def active_filters_for(group)
        values = public_send(group)

        values.map do |value|
          label = label_for(group, value)

          ::Courses::ActiveFilter.new(
            id: group,
            raw_value: value,
            value: label,
            formatted_value: label,
            remove_params: ::Courses::ActiveFilters::RemovalParams.new(
              search_params: filter_params, attribute: group, current_value: value, all_values: values,
            ).call,
          )
        end
      end

      # Only the months the provider's courses actually start in, so the panel
      # never offers a month that would narrow the list to nothing.
      def start_date_options
        @start_date_options ||= ::Publish::Courses::AvailableStartMonths.for(provider).map do |month|
          Option.new(value: month.to_fs(:year_and_month), label: I18n.l(month, format: :short))
        end
      end

      def static_options_for(group)
        STATIC_OPTIONS.fetch(group).map do |value|
          Option.new(value:, label: I18n.t("publish.courses.filters.options.#{group}.#{value}"))
        end
      end

      def allowed_values_for(group)
        options_for(group).map(&:value)
      end

      def label_for(group, value)
        options_for(group).find { |option| option.value == value }&.label
      end
    end
  end
end
