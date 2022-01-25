module Courses
  class Fetch
    class << self
      def by_code(provider_code:, course_code:, cycle_year: Settings.current_recruitment_cycle_year)
        Course
          .includes(:subjects)
          .includes(:sites)
          .includes(provider: [:sites])
          .includes(:accrediting_provider)
          .where(recruitment_cycle_year: cycle_year)
          .where(provider_code: provider_code)
          .find(course_code)
          .first
      end

      def by_accrediting_provider(provider)
        # rubocop:disable Style/MultilineBlockChain
        # rubocop:disable Style/HashTransformValues
        provider
          .courses
          .group_by do |course|
            # HOTFIX: A courses API response no included hash seems to cause issues with the
            # .accrediting_provider relationship lookup. To be investigated, for now,
            # if this throws, it's self-accredited.
            course.accrediting_provider&.provider_name || provider.provider_name
          rescue StandardError
            provider.provider_name
          end
          .sort_by { |accrediting_provider, _| accrediting_provider.downcase }
          .to_h do |provider_name, courses|
            [provider_name, courses.sort_by { |course| [course.name, course.course_code] }.map(&:decorate)]
          end
        # rubocop:enable Style/MultilineBlockChain
        # rubocop:enable Style/HashTransformValues
      end
    end
  end
end
