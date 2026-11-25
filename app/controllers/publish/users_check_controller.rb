# frozen_string_literal: true

module Publish
  class UsersCheckController < ApplicationController
    include ReturnToSupport
    include ReturnPaths::Users

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

    def cycle_year
      params[:recruitment_cycle_year] ||
        support_flow_params[:recruitment_cycle_year] ||
        params[:year] ||
        session[:cycle_year] ||
        Find::CycleTimetable.current_year
    end

    def user
      User.find_or_initialize_by(email: params.dig(:publish_user_form, :email)&.downcase)
    end
  end
end
