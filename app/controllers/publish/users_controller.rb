# frozen_string_literal: true

module Publish
  class UsersController < ApplicationController
    include ReturnToSupport

    USERS_PER_PAGE = 20

    def index
      @sort = params[:sort] == "last_signed_in" ? "last_signed_in" : "name"
      users = @sort == "last_signed_in" ? provider.users.by_most_recent_sign_in : provider.users.in_name_order
      @pagy, @users = pagy(users, limit: USERS_PER_PAGE)
    end

    def show
      provider_user
    end

    def delete
      provider_user
    end

    def new
      @user_form = UserForm.new(current_user, user)
      @user_form.clear_stash
    end

    def edit
      @user_form = UserForm.new(current_user, provider_user)
      @user_form.clear_stash
    end

    def create
      @user_form = UserForm.new(current_user, user, params: user_params, provider:)
      if @user_form.stash
        redirect_to publish_provider_check_user_path(provider_code: params[:provider_code], **support_return_params)
      else
        render(:new)
      end
    end

    def update
      provider
      @user_form = UserForm.new(current_user, provider_user, params: user_params)
      if @user_form.stash
        redirect_to publish_provider_user_edit_check_path(user_id: params[:id])
      else
        render(:edit)
      end
    end

    def destroy
      UserAssociationsService::Delete.call(user: provider_user, providers: provider)
      flash[:success] = user_removal_success_message
      redirect_to return_path(support_users_list_params_after_removal)
    end

  private

    def cycle_year
      params[:recruitment_cycle_year] || params[:year] || session[:cycle_year] || Find::CycleTimetable.current_year
    end

    def user
      User.find_or_initialize_by(email: params.dig(:publish_user_form, :email)&.downcase)
    end

    def user_params
      params.expect(publish_user_form: %i[first_name last_name email]).except(:code, :authenticity_token)
    end

    def provider_user
      @provider_user ||= provider.users.find(params[:id])
    end

    def user_delete_path_with_return
      delete_publish_provider_user_path(
        provider_code: params[:provider_code],
        id: params[:id],
        **user_delete_flow_params,
      )
    end
    helper_method :user_delete_path_with_return

    def user_delete_flow_params
      {}.tap do |permitted|
        permitted[:return_to] = "support" if returning_to_support?
        permitted[:from] = params[:from] if params[:from].present?
        permitted[:page] = params[:page] if params[:page].present?
        permitted[:sort] = params[:sort] if params[:sort].present?
        if params[:recruitment_cycle_year].present?
          permitted[:recruitment_cycle_year] = params[:recruitment_cycle_year]
        end
      end
    end
    helper_method :user_delete_flow_params

    def user_delete_return_path
      if returning_to_support?
        return return_path if params[:from] == "index"

        support_recruitment_cycle_provider_user_path(
          provider.recruitment_cycle_year,
          provider,
          provider_user,
        )
      else
        publish_provider_user_path(id: params[:id])
      end
    end
    helper_method :user_delete_return_path

    def user_removal_success_message
      if returning_to_support?
        I18n.t(
          "publish.users.delete.removed_from_provider",
          name: provider_user.full_name,
          provider: provider.provider_name,
        )
      else
        I18n.t("success.user_removed")
      end
    end

    def support_users_list_params_after_removal
      {}.tap do |permitted|
        if params[:page].present?
          page = [params[:page].to_i, last_support_users_page].min
          permitted[:page] = page if page > 1
        end

        permitted[:sort] = params[:sort] if params[:sort].present?
      end
    end

    def last_support_users_page
      # Association may already be loaded (e.g. via provider_user); reload so the
      # post-removal count is accurate when clamping the return page.
      total = provider.users.reload.count
      return 1 if total.zero?

      (total.to_f / Support::Providers::UsersController::USERS_PER_PAGE).ceil
    end

    def support_flow_params
      {}.tap do |permitted|
        if params[:recruitment_cycle_year].present?
          permitted[:recruitment_cycle_year] = params[:recruitment_cycle_year]
        end
      end
    end

    def support_list_params
      {}.tap do |permitted|
        permitted[:page] = params[:page] if params[:page].present?
        permitted[:sort] = params[:sort] if params[:sort].present?
      end
    end

    def support_return_path(**list_params)
      support_recruitment_cycle_provider_users_path(
        provider.recruitment_cycle_year,
        provider,
        **list_params,
      )
    end

    def publish_return_path
      publish_provider_users_path(params[:provider_code])
    end
  end
end
