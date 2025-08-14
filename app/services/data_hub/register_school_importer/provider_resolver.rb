module DataHub
  module RegisterSchoolImporter
    class ProviderResolver
      HPITT_PROVIDERS = %w[1TF].freeze
      IGNORED_PROVIDER_CODES = [HPITT_PROVIDERS].flatten

      def initialize(recruitment_cycle, parser)
        @recruitment_cycle = recruitment_cycle
        @parser = parser
      end

      def resolve
        provider_code = @parser.provider_code
        return nil unless provider_code
        return nil if IGNORED_PROVIDER_CODES.include?(provider_code)

        @recruitment_cycle.providers.find_by(provider_code:)
      end
    end
  end
end
