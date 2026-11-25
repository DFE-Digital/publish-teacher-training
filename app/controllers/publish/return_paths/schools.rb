# frozen_string_literal: true

module Publish
  module ReturnPaths
    module Schools
    private

      def support_return_path(state)
        support_recruitment_cycle_provider_schools_path(
          provider.recruitment_cycle_year,
          provider,
          **state.slice(:page),
        )
      end

      def publish_return_path
        publish_provider_recruitment_cycle_schools_path
      end
    end
  end
end
