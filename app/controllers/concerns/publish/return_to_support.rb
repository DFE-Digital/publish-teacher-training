# frozen_string_literal: true

module Publish
  module ReturnToSupport
    extend ActiveSupport::Concern

    included do
      helper_method :user_add_flow_params,
                    :user_delete_flow_params,
                    :user_delete_path_with_return,
                    :user_delete_return_path,
                    :users_return_path,
                    :returning_to_support?
    end

  private

    def returning_to_support?
      params[:return_to] == "support" && current_user.admin?
    end

    def user_add_flow_params
      {}.tap do |permitted|
        permitted[:return_to] = "support" if returning_to_support?
        if params[:recruitment_cycle_year].present?
          permitted[:recruitment_cycle_year] = params[:recruitment_cycle_year]
        end
      end
    end

    def user_delete_flow_params
      {}.tap do |permitted|
        permitted[:return_to] = "support" if returning_to_support?
        permitted[:from] = params[:from] if params[:from].present?
        permitted[:page] = params[:page] if params[:page].present?
        if params[:recruitment_cycle_year].present?
          permitted[:recruitment_cycle_year] = params[:recruitment_cycle_year]
        end
      end
    end

    def user_delete_path_with_return
      delete_publish_provider_user_path(
        provider_code: params[:provider_code],
        id: params[:id],
        **user_delete_flow_params,
      )
    end

    def user_delete_return_path
      if returning_to_support?
        return users_return_path if params[:from] == "index"

        support_recruitment_cycle_provider_user_path(
          provider.recruitment_cycle_year,
          provider,
          provider_user,
        )
      else
        publish_provider_user_path(id: params[:id])
      end
    end

    def users_return_path(clamp_page: false)
      if returning_to_support?
        support_recruitment_cycle_provider_users_path(
          provider.recruitment_cycle_year,
          provider,
          **support_list_page_params(clamp: clamp_page),
        )
      else
        publish_provider_users_path(params[:provider_code])
      end
    end

    def support_list_page_params(clamp: false)
      return {} if params[:page].blank?

      return { page: params[:page] } unless clamp

      page = [params[:page].to_i, last_support_users_page].min
      return {} if page <= 1

      { page: page }
    end

    def last_support_users_page
      # Association may already be loaded (e.g. via provider_user); reload so the
      # post-removal count is accurate when clamping the return page.
      total = provider.users.reload.count
      return 1 if total.zero?

      (total.to_f / Support::Providers::UsersController::USERS_PER_PAGE).ceil
    end
  end
end
