module Courses
  class ActiveFilter
    attr_reader :id, :raw_value, :value, :formatted_value, :remove_params

    def initialize(id:, raw_value:, value:, remove_params:)
      @id = id
      @raw_value = raw_value
      @value = value
      @remove_params = remove_params
      @formatted_value = translate
    end

    def translate
      return value if id.in?(%i[provider_code subjects subject_code subject_name short_address])

      begin
        translated = I18n.t(".courses.active_filters.#{id}.#{raw_value}")
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
