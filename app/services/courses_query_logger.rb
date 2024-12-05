# frozen_string_literal: true

class CoursesQueryLogger
  def initialize(applied_filters, scope, explain: false)
    @applied_filters = applied_filters
    @scope = scope
    @log_tag = self.class.name
    @logger = Rails.logger
    @explain = explain
  end

  def call
    log_filters
    log_query
  end

  private

  def log_filters
    return unless Rails.env.local?

    if @applied_filters.blank?
      @logger.tagged(@log_tag) { @logger.debug('No filters applied'.colorize(:red)) }
    else
      @logger.tagged(@log_tag) do
        @logger.debug('Applied Filters:'.colorize(:green))
        @applied_filters.each do |filter|
          @logger.debug("* #{filter[:name]} => #{filter[:value]}".colorize(:green))
        end
      end
    end
  end

  def log_query
    return unless Rails.env.local?

    @logger.tagged(@log_tag) do
      @logger.debug("Full query: #{@scope.to_sql.colorize(:green)}")

      @logger.debug("EXPLAIN Output: #{@scope.explain(:analyze).inspect}".colorize(:yellow)) if @explain
    end
  end
end
