# frozen_string_literal: true

module Find
  class SearchParamDefaults
    def initialize(search_params)
      @params = search_params.to_h.with_indifferent_access
    end

    def default_value?(key, value)
      default = default_for(key)
      return false if default.nil?

      value.to_s == default.to_s
    end

    def non_default?(key, value)
      !default_value?(key, value)
    end

  private

    def default_for(key)
      entry = defaults[key.to_s]
      entry.is_a?(Proc) ? entry.call(@params) : entry
    end

    def defaults
      {
        "applications_open" => "true",
        "minimum_degree_required" => "show_all_courses",
        "order" => proc { |params| location_based?(params) ? "distance" : "course_name_ascending" },
        "level" => "all",
      }
    end

    def location_based?(params)
      params["short_address"].present? || params["longitude"].present?
    end
  end
end
