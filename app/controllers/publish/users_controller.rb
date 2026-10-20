# frozen_string_literal: true

module Publish
  class UsersController < ApplicationController
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
        redirect_to publish_provider_check_user_path(provider_code: params[:provider_code])
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
      flash[:success] = I18n.t("success.user_removed")
      redirect_to publish_provider_users_path(params[:provider_code])
    end

  private

    def cycle_year
      session[:cycle_year] || params[:recruitment_cycle_year] || params[:year] || Find::CycleTimetable.current_year
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
  end
end
