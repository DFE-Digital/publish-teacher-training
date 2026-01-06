module Courses
  class ActiveFilterExtractor
    ACTIVE_FILTER_ORDER = %i[
      order
      short_address
      radius
      provider_code
      subjects
      subject_code
      subject_name
      engineers_teach_physics
      level
      send_courses
      funding
      study_types
      qualifications
      minimum_degree_required
      can_sponsor_visa
      interview_location
      start_date
    ].freeze

    def initialize(search_params:, search_form:)
      @search_params = search_params
      @search_form = search_form
    end

    def call
      filters = @search_params
        .flat_map { |attribute, value| process_attribute(attribute, value) }
        .compact
        .reject { |filter| filter.formatted_value.blank? }

      sort_filters(filters).uniq(&:formatted_value)
    end

  private

    def sort_filters(filters)
      order = ACTIVE_FILTER_ORDER

      filters.sort_by do |filter|
        # Primary sort: by position in ACTIVE_FILTER_ORDER
        type_index = order.index(filter.id)
        type_order = type_index.nil? ? order.length : type_index

        # Secondary sort: within same type, maintain original value order
        # This preserves the order of array elements (subjects: [01, C1, 08])
        value_index = Array(@search_params[filter.id]).index(filter.raw_value)
        value_order = value_index.nil? ? 0 : value_index

        [type_order, value_order]
      end
    end

    def process_attribute(attribute, value)
      return [] if value.blank?
      return [] if skip_condition?(attribute) || skip_default?(attribute, value)

      valid_values = filter_valid_values(attribute, value)
      return [] if valid_values.blank?

      build_filters(attribute, valid_values)
    end

    def skip_condition?(attribute)
      condition = conditions[attribute]
      condition && !condition.call(@search_params)
    end

    def skip_default?(attribute, value)
      default = resolve_default(attribute)

      value.to_s == default.to_s
    end

    def resolve_default(attribute)
      default = defaults[attribute]

      default.is_a?(Proc) ? default.call(@search_params) : default
    end

    def filter_valid_values(attribute, value)
      valid_values_set = resolve_valid_values(attribute)
      return value unless valid_values_set # No validation rules = accept all

      values_to_check = Array(value)
      values_to_check.select { |val| valid_values_set.include?(val) }
    end

    def resolve_valid_values(attribute)
      resolver = value_resolvers[attribute]
      resolver&.call(@search_form)
    end

    def resolve_formatted_value(attribute, raw_value)
      resolver = formatter_resolvers[attribute]
      resolver ? resolver.call(@search_form, raw_value) : raw_value
    end

    def build_filters(attribute, value)
      return [build_location_filter(value)] if attribute == :short_address

      Array(value).map { |val| build_filter(attribute, val, value) }
    end

    def build_filter(attribute, current_value, all_values)
      ActiveFilter.new(
        id: attribute,
        raw_value: current_value,
        value: resolve_formatted_value(attribute, current_value),
        remove_params: compute_removal_params(attribute, current_value, all_values),
      )
    end

    def compute_removal_params(attribute, current_value, all_values)
      remaining_values = Array(all_values) - [current_value]

      { attribute => remaining_values.presence }
    end

    def build_location_filter(value)
      ActiveFilter.new(
        id: :short_address,
        raw_value: value,
        value: value,
        remove_params: { location: nil, radius: nil },
      )
    end

    def defaults
      {
        order: proc { |params| params[:short_address].present? ? "distance" : "course_name_ascending" },
        level: "all",
        minimum_degree_required: "show_all_courses",
        radius: proc { |_params|
          DefaultRadius.new(
            location: @search_form.location,
            formatted_address: @search_form.formatted_address,
            address_types: @search_form.address_types,
          ).call
        },
      }
    end

    def conditions
      {
        radius: proc { |params| params[:short_address].present? },
      }
    end

    def value_resolvers
      {
        subjects: ->(form) { form.all_subjects.map(&:value) },
        subject_code: ->(form) { form.all_subjects.map(&:value) },
        provider_code: ->(form) { form.providers_list.map(&:code) },
        funding: ->(form) { form.funding_options },
        study_types: ->(form) { form.study_type_options },
        qualifications: ->(form) { form.qualification_options },
        start_date: ->(form) { form.start_date_options },
        minimum_degree_required: ->(form) { form.minimum_degree_required_options },
      }
    end

    def formatter_resolvers
      {
        subjects: ->(form, value) { form.all_subjects.find { |s| s.value == value }&.name || value },
        subject_code: ->(form, value) { form.all_subjects.find { |s| s.value == value }&.name || value },
        provider_code: ->(form, value) { form.providers_list.find { |p| p.code == value }&.name || value },
      }
    end
  end
end
