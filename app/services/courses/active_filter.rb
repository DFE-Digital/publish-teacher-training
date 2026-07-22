module Courses
  class ActiveFilter
    attr_reader :id, :raw_value, :value, :formatted_value, :remove_params

    # formatted_value lets a caller supply the chip label directly, for filters
    # whose label cannot be a fixed translation key — a start month, say. Left
    # out, the label is translated from the id and raw value as before, and a
    # missing translation still rejects the filter.
    def initialize(id:, raw_value:, value:, remove_params:, formatted_value: nil)
      @id = id
      @raw_value = raw_value
      @value = value
      @remove_params = remove_params
      @formatted_value = formatted_value.presence || translate
    end

    def translate
      return value if id.in?(%i[provider_code subjects subject_code subject_name short_address])

      begin
        this_year = Find::CycleTimetable.current_year
        next_year = Find::CycleTimetable.next_year
        translated = I18n.t(".courses.active_filters.#{id}.#{raw_value}",
                            current_recruitment_cycle_year: this_year,
                            next_recruitment_cycle_year: next_year)

        translated.starts_with?("Translation missing") ? nil : translated
      rescue StandardError
        nil
      end
    end

    def ==(other)
      id == other.id &&
        raw_value == other.raw_value &&
        value == other.value &&
        remove_params == other.remove_params
    end

    alias_method :eql?, :==

    def hash
      [id, raw_value, value, remove_params].hash
    end
  end
end
