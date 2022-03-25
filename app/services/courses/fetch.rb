module Courses
  class Fetch
    class << self
      def by_code(provider_code:, course_code:)
        RecruitmentCycle.current.providers
          .find_by(provider_code: provider_code)
          .courses
          .find_by(course_code: course_code)
      end

      def by_accrediting_provider(provider)
        # rubocop:disable Style/MultilineBlockChain
        # rubocop:disable Style/HashTransformValues
        provider
          .courses
          .group_by do |course|
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
