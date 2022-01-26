# frozen_string_literal: true

module PublishInterface
  class FormStore
    class InvalidKeyError < StandardError; end

    FORM_SECTION_KEYS = %i[
      course_level
    ].freeze

    class << self
      def get(key)
        value = Redis.current.get(key)
        JSON.parse(value) if value.present?
      end

      def set(key, values)
        raise(InvalidKeyError) unless FORM_SECTION_KEYS.include?(key)

        Redis.current.set(key, values.to_json)

        true
      end

      def clear_all
        FORM_SECTION_KEYS.each do |key|
          Redis.current.set(key, nil)
        end
      end
    end
  end
end
