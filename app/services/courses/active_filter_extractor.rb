module Courses
  class ActiveFilterExtractor
    def initialize(search_params:, search_form:)
      @search_params = search_params
      @search_form = search_form
    end

    def call
      @search_params
        .flat_map { |attribute, value| process_attribute(attribute, value) }
        .compact
        .reject { |filter| filter.formatted_value.blank? }
    end

  private

    def process_attribute(attribute, value)
      return [] if value.blank?
      return [] if skip_condition?(attribute) || skip_default?(attribute, value) || skip_invalid?(attribute, value)

      build_filters(attribute, value)
    end

    def skip_condition?(attribute)
      condition = conditions[attribute.to_sym]
      condition && !condition.call(@search_params)
    end

    def skip_default?(attribute, value)
      default = resolve_default(attribute)
      value == default
    end

    def resolve_default(attribute)
      default = defaults[attribute.to_sym]
      default.is_a?(Proc) ? default.call(@search_params) : default
    end

    def skip_invalid?(attribute, value)
      valid_values = resolve_valid_values(attribute)
      return false unless valid_values

      values_to_validate = Array(value)
      values_to_validate.any? { |val| !valid_values.include?(val) }
    end

    def resolve_valid_values(attribute)
      resolver = value_resolvers[attribute.to_sym]
      resolver&.call(@search_form)
    end

    def resolve_formatted_value(attribute, raw_value)
      resolver = formatter_resolvers[attribute.to_sym]
      resolver ? resolver.call(@search_form, raw_value) : raw_value
    end

    def build_filters(attribute, value)
      return [build_location_filter(value)] if attribute.to_sym == :short_address

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

      { attribute.to_sym => remaining_values.presence }
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
        applications_open: true,
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
