# frozen_string_literal: true

module Publish
  module ReturnPaths
    module Users
    private

      def support_return_path(state)
        support_recruitment_cycle_provider_users_path(
          provider.recruitment_cycle_year,
          provider,
          **state.slice(:page, :sort),
        )
      end

      def publish_return_path
        publish_provider_users_path(params[:provider_code])
      end
    end
  end
end
