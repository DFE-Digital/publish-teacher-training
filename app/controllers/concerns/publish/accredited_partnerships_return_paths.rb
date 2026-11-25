# frozen_string_literal: true

module Publish
  module AccreditedPartnershipsReturnPaths
    extend ActiveSupport::Concern

    include ReturnToSupport

  private

    def support_return_path
      support_recruitment_cycle_provider_accredited_partnerships_path(
        provider.recruitment_cycle_year,
        provider,
      )
    end

    def publish_return_path
      publish_provider_recruitment_cycle_accredited_partnerships_path(
        provider.provider_code,
        provider.recruitment_cycle_year,
      )
    end
  end
end
