# frozen_string_literal: true

module CourseFilters
  class BaseFilter
    delegate :filter, to: :course_search_service
    attr_reader :course_search_service

    def initialize(course_search_service)
      @course_search_service = course_search_service
    end

    def applicable_filter?
      log_filters
      add_filter?
    end

    def call(scope)
      raise NotImplementedError, 'Subclasses must implement the #call method'
    end

    def add_filter?
      raise NotImplementedError, 'Subclasses must implement the #add_filter? method'
    end

    private

    # Purple in the logs when filter is applied, Dark Red for not applied
    FILTER_APPLIED_COLOR = "\e[35m"
    FILTER_NOT_APPLIED_COLOR = "\e[31m"

    def log_filters
      return unless Rails.env.local?

      color = add_filter? ? FILTER_APPLIED_COLOR : FILTER_NOT_APPLIED_COLOR
      reset = "\e[0m" # Reset to default color

      Rails.logger.info("#{color}#{self.class} filter #{add_filter? ? 'applied' : 'NOT applied'}#{reset}")
    end
  end
end
