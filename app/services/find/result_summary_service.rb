# frozen_string_literal: true

module Find
  class ResultSummaryService
    include ActionView::Helpers::NumberHelper

    attr_reader :results

    def initialize(results:)
      @results = results
    end

    class << self
      def call(...)
        new(...).call
      end
    end

    def call
      [
        course_found_text,
        subject_names,
        with_location_text,
        with_england_text,
        with_provider_text
      ].compact.join(' ')
    end

    private

    def subject_names
      results.subjects.map { |subject| subject[:subject_name].downcase }.to_sentence(last_word_connector: ' and ')
    end

    def course_found_text
      case results.course_count
      when 0
        'No'
      when 1
        '1'
      else
        number_with_delimiter(results.course_count)
      end
    end

    def course_string_modifier
      return 'courses found' if results.course_count.zero?
      return 'course' if results.course_count == 1

      'courses'
    end

    def with_location_text
      "#{course_string_modifier} in #{results.location_search}" if results.location_filter?
    end

    def with_england_text
      "#{course_string_modifier} in England" if results.england_filter?
    end

    def with_provider_text
      "#{course_string_modifier} from #{results.provider}" if results.provider_filter?
    end
  end
end
