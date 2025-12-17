module Courses
  class ActiveFilterExtractor
    DEFAULTS = {
      order: proc { |p| p[:short_address].present? ? "distance" : "course_name_ascending" },
      level: "all",
      minimum_degree_required: "show_all_courses",
      applications_open: true,
    }.freeze

    CONDITIONS = {
      radius: proc { |p| p[:short_address].present? },
    }.freeze

    def initialize(search_params:, search_form:)
      @search_params = search_params
      @search_form = search_form
    end

    def call
      active_filters = @search_params.flat_map { |attribute, value|
        next [] if value.blank?
        next [] if skip_by_condition?(attribute)
        next [] if skip_by_default?(attribute, value)
        next [] if skip_invalid_filter?(attribute, value)

        build_filter_list(attribute, value)
      }.compact

      active_filters.reject { |active_filter| active_filter.formatted_value.blank? }
    end

  private

    def skip_by_condition?(attribute)
      condition = CONDITIONS[attribute.to_sym]
      condition && !condition.call(@search_params)
    end

    def skip_by_default?(attribute, value)
      default = DEFAULTS[attribute.to_sym]
      default = default.is_a?(Proc) ? default.call(@search_params) : default
      value == default
    end

    def skip_invalid_filter?(attribute, value)
      valid_values = resolve_valid_values(attribute)
      return false unless valid_values

      case value
      when Array
        value.any? { |v| !valid_values.include?(v) }
      else
        !valid_values.include?(value)
      end
    end

    def resolve_valid_values(attribute)
      case attribute.to_sym
      when :subjects, :subject_code
        @search_form.all_subjects.map(&:value)
      when :provider_code
        @search_form.providers_list.map(&:code)
      when :funding
        @search_form.funding_options
      when :study_types
        @search_form.study_type_options
      when :qualifications
        @search_form.qualification_options
      when :start_date
        @search_form.start_date_options
      when :minimum_degree_required
        @search_form.minimum_degree_required_options
      end
    end

    def resolve_value(attribute, raw_value)
      case attribute.to_sym
      when :subjects, :subject_code
        @search_form.all_subjects.find { |s| s.value == raw_value }&.name || raw_value
      when :provider_code
        @search_form.providers_list.find { |p| p.code == raw_value }&.name || raw_value
      else
        raw_value
      end
    end

    def build_filter_list(attribute, value)
      return build_location_active_filter(value) if attribute.to_sym == :short_address

      case value
      when Array
        value.map do |v|
          remaining = value - [v]
          ActiveFilter.new(
            id: attribute,
            raw_value: v,
            value: resolve_value(attribute, v),
            remove_params: { attribute.to_sym => remaining.presence },
          )
        end
      else
        [ActiveFilter.new(
          id: attribute,
          raw_value: value,
          value: resolve_value(attribute, value),
          remove_params: { attribute.to_sym => nil },
        )]
      end
    end

    def build_location_active_filter(value)
      ActiveFilter.new(
        id: :short_address,
        raw_value: value,
        value:,
        remove_params: { location: nil, radius: nil },
      )
    end
  end
end
