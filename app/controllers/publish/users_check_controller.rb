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
      redirect_to users_added_redirect_path, flash: { success: "User added" }
    end

  private

    def user
      User.find_or_initialize_by(email: params.dig(:publish_user_form, :email)&.downcase)
    end
  end
end
