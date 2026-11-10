# frozen_string_literal: true

module Publish
  module ReturnToSupport
    extend ActiveSupport::Concern

    included do
      helper_method :user_add_flow_params, :users_cancel_path, :returning_to_support?
    end

  private

    def returning_to_support?
      params[:return_to] == "support"
    end

    def user_add_flow_params
      {}.tap do |permitted|
        permitted[:return_to] = "support" if returning_to_support?
        if params[:recruitment_cycle_year].present?
          permitted[:recruitment_cycle_year] = params[:recruitment_cycle_year]
        end
      end
    end

    def users_cancel_path
      if returning_to_support?
        support_recruitment_cycle_provider_users_path(provider.recruitment_cycle_year, provider)
      else
        publish_provider_users_path(params[:provider_code])
      end
    end

    def users_added_redirect_path
      if returning_to_support?
        support_recruitment_cycle_provider_users_path(provider.recruitment_cycle_year, provider)
      else
        publish_provider_users_path(params[:provider_code])
      end
    end
  end
end
