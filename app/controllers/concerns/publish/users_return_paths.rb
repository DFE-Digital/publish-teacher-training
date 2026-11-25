# frozen_string_literal: true

module Publish
  module UsersReturnPaths
    extend ActiveSupport::Concern

    include ReturnToSupport

  private

    def support_flow_params
      params[:recruitment_cycle_year].present? ? { recruitment_cycle_year: params[:recruitment_cycle_year] } : {}
    end

    def support_return_path
      support_recruitment_cycle_provider_users_path(
        provider.recruitment_cycle_year,
        provider,
      )
    end

    def publish_return_path
      publish_provider_users_path(params[:provider_code])
    end

    def user
      User.find_or_initialize_by(email: params.dig(:publish_user_form, :email)&.downcase)
    end
  end
end
