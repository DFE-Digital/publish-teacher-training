# frozen_string_literal: true

module Courses
  class Fetch
    class << self
      def by_code(provider_code:, course_code:, recruitment_cycle_year:)
        RecruitmentCycle.find_by(year: recruitment_cycle_year).providers
                        .find_by(provider_code:)
                        .courses
                        .find_by(course_code:)
      end

      def by_accrediting_provider(provider)
        sort_courses_by_accredited_provider(provider) do |provider_name, courses|
          [provider_name, courses.sort_by { |course| [course.name, course.course_code] }.map(&:decorate)]
        end
      end

      def by_accrediting_provider_dynamically_sorted_list(provider, sort:, direction:)
        courses_by_provider = sort_courses_by_accredited_provider(provider)

        courses_by_provider.transform_values do |courses|
          sorted_courses = courses.sort_by { |course| sort_column(course, sort) }
          sorted_courses.reverse! if sort_direction(direction) == 'descending'
          sorted_courses.map(&:decorate)
        end
      end

      private

      def sort_courses_by_accredited_provider(provider)
        # rubocop:disable Style/MultilineBlockChain
        provider
          .courses
          .group_by do |course|
          course.accrediting_provider&.provider_name || provider.provider_name
        rescue StandardError
          provider.provider_name
        end
        .sort_by { |accrediting_provider, _| accrediting_provider.downcase }
          .to_h
        # rubocop:enable Style/MultilineBlockChain
      end

      def sort_column(course, sort)
        sort == 'status' ? status_order(course) : course.name
      end

      def sort_direction(direction)
        %w[ascending descending].include?(direction) ? direction : 'ascending'
      end

      def status_order(course)
        content_status_order = %i[draft rolled_over scheduled open closed published_with_unpublished_changes published withdrawn]
        application_status_order = { 'open' => 0, 'closed' => 1 }

        content_index = content_status_order.index(course.content_status) || content_status_order.size
        application_index = application_status_order[course.application_status] || application_status_order.size

        [content_index, application_index]
      end
    end
  end
end
