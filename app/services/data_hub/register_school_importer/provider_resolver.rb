module DataHub
  module RegisterSchoolImporter
    class ProviderResolver
      def initialize(recruitment_cycle, parser)
        @recruitment_cycle = recruitment_cycle
        @parser = parser
      end

      def resolve
        provider_code = @parser.provider_code
        return nil unless provider_code

        @recruitment_cycle.providers.find_by(provider_code:)
      end
    end
  end
end
