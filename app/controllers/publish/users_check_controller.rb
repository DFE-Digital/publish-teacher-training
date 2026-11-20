# frozen_string_literal: true

module Publish
  class UsersCheckController < ApplicationController
    include ReturnToSupport

    def show
      @user_form = UserForm.new(current_user, user)
    end

    def update
      @user_form = UserForm.new(current_user, user)
      return unless @user_form.save!

      UserAssociationsService::Create.call(user: @user_form.model, provider:) if @user_form.model.providers.exclude?(provider)
      redirect_to return_path, flash: { success: I18n.t("success.user_added") }
    end

  private

    def user
      User.find_or_initialize_by(email: params.dig(:publish_user_form, :email)&.downcase)
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
