# frozen_string_literal: true

module Rollover
  module Schools
    class LegacyProviderCopier
      def initialize(site_copier:)
        @site_copier = site_copier
      end

      def execute(provider:, new_provider:)
        result = { copied: 0, skipped: [] }

        provider.sites.each do |site|
          site_result = site_copier.execute(site:, new_provider:)

          if site_result.success?
            result[:copied] += 1
          else
            result[:skipped] << { site_code: site.code, reason: site_result.error_message }
          end
        end

        result
      end

    private

      attr_reader :site_copier
    end
  end
end
