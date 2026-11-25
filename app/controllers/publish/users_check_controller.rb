# frozen_string_literal: true

module Publish
  class UsersCheckController < ApplicationController
    include ReturnToSupport
    include ReturnPaths::Users
    include UsersCycleYear

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
  end
end
