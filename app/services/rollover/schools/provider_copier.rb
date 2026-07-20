# frozen_string_literal: true

module Rollover
  module Schools
    class ProviderCopier
      def execute(provider:, new_provider:)
        provider.schools.each do |provider_school|
          new_provider.schools.find_or_create_by!(uuid: provider_school.uuid) do |new_provider_school|
            new_provider_school.gias_school_id = provider_school.gias_school_id
            new_provider_school.site_code = provider_school.site_code
          end
        end

        { copied: provider.schools.size, skipped: [] }
      end
    end
  end
end
