# frozen_string_literal: true

module Support
  module Providers
    class UsersController < ApplicationController
      USERS_PER_PAGE = 20

      def index
        @sort = params[:sort] == "last_signed_in" ? "last_signed_in" : "name"
        users = @sort == "last_signed_in" ? provider.users.by_most_recent_sign_in : provider.users.in_name_order
        @pagy, @users = pagy(users, limit: USERS_PER_PAGE)
      end

      def show
        recruitment_cycle
        provider_user
      end

      def delete
        provider_user
      end

      def new
        provider
        @user_form = UserForm.new(current_user, user)
        @user_form.clear_stash
      end

      def edit
        provider
        provider_user
        @user_form = UserForm.new(current_user, provider_user)
      end

      def create
        provider
        @user_form = UserForm.new(current_user, user, params: user_params, provider:)
        if @user_form.stash
          redirect_to support_recruitment_cycle_provider_check_user_path
        else
          render(:new)
        end
      end

      def update
        provider
        @user_form = UserForm.new(current_user, provider_user, params: user_params)
        if @user_form.save!
          redirect_to support_recruitment_cycle_provider_user_path(provider.recruitment_cycle_year, provider)
          flash[:success] = "User updated"
        else
          render(:edit)
        end
      end

      def destroy
        UserAssociationsService::Delete.call(user: provider_user, providers: provider)
        flash[:success] = I18n.t("success.user_removed")
        redirect_to support_recruitment_cycle_provider_users_path(provider.recruitment_cycle_year, provider)
      end

    private

      def user
        User.find_or_initialize_by(email: params.dig(:support_user_form, :email)&.downcase)
      end

      def user_params
        params.expect(support_user_form: %i[first_name last_name email])
      end

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end

      def provider_user
        @provider_user ||= provider.users.find(params[:id])
      end
    end
  end
end
