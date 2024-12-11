# frozen_string_literal: true

module Find
  module ResultsSummary
    class View < ViewComponent::Base
      attr_reader :courses_count

      def initialize(courses_count:)
        super
        @courses_count = courses_count
      end

      def title
        I18n.t('find.results_summary.title', count: courses_count, formatted_count: number_with_delimiter(courses_count))
      end
    end
  end
end
