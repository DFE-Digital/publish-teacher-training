# frozen_string_literal: true

module Rollover
  module Schools
    class ProviderCopier
      def execute(provider:, new_provider:)
        existing = new_provider.schools.index_by { |school| [school.gias_school_id, school.site_code] }
        result = { copied: 0, skipped: [], already_present: [] }

        provider.schools.with_available_gias_school.each do |provider_school|
          key = [provider_school.gias_school_id, provider_school.site_code]

          if existing.key?(key)
            result[:already_present] << provider_school.site_code
            next
          end

          existing[key] = new_provider.schools.create!(
            gias_school_id: provider_school.gias_school_id,
            site_code: provider_school.site_code,
          )
          result[:copied] += 1
        end

        result
      end
    end
  end
end
