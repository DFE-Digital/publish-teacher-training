# frozen_string_literal: true

module Rollover
  module Schools
    class NewProviderCopier
      def execute(provider:, new_provider:)
        provider.schools.each do |provider_school|
          new_provider.schools.find_or_create_by!(
            gias_school_id: provider_school.gias_school_id,
            site_code: provider_school.site_code,
          )
        end

        { copied: provider.schools.size, skipped: [] }
      end
    end
  end
end
