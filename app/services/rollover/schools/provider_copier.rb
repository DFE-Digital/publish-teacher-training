# frozen_string_literal: true

module Rollover
  module Schools
    class ProviderCopier
      def execute(provider:, new_provider:)
        existing = new_provider.schools.index_by { |school| [school.gias_school_id, school.site_code] }

        provider.schools.each do |provider_school|
          key = [provider_school.gias_school_id, provider_school.site_code]
          next if existing.key?(key)

          existing[key] = new_provider.schools.create!(
            gias_school_id: provider_school.gias_school_id,
            site_code: provider_school.site_code,
          )
        end

        { copied: provider.schools.size, skipped: [] }
      end
    end
  end
end
