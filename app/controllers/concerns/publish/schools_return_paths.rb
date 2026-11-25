# frozen_string_literal: true

module Publish
  module SchoolsReturnPaths
    extend ActiveSupport::Concern

    include ReturnToSupport

  private

    def support_flow_params
      params[:page].present? ? { page: params[:page] } : {}
    end

    def support_return_path
      support_recruitment_cycle_provider_schools_path(
        provider.recruitment_cycle_year,
        provider,
        **support_flow_params,
      )
    end

    def publish_return_path
      publish_provider_recruitment_cycle_schools_path
    end
  end
end
