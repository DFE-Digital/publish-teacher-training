# frozen_string_literal: true

class CoursesQuery
  class Logger
    attr_reader :courses_query

    delegate :scope, :applied_scopes, to: :courses_query

    def initialize(courses_query, explain: false)
      @courses_query = courses_query
      @explain = explain
    end

    def call
      return unless Rails.env.local?

      log_filters
      log_query
    end

    private

    def log_filters
      if applied_scopes.blank?
        logger.tagged(log_tag) { logger.debug('No filters applied'.colorize(:red)) }
      else
        logger.tagged(log_tag) do
          logger.debug('Applied Filters:'.colorize(:green))
          applied_scopes.each do |name, value|
            logger.debug("* #{name} => #{value}".colorize(:light_blue))
          end
        end
      end
    end

    def log_query
      logger.tagged(log_tag) do
        logger.debug("Full query: #{scope.to_sql.colorize(:green)}")

        logger.debug("EXPLAIN Output: #{scope.explain(:analyze).inspect}".colorize(:yellow)) if @explain
      end
    end

    def log_tag
      self.class.name
    end

    def logger
      Rails.logger
    end
  end
end
