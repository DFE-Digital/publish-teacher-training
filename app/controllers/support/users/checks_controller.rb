# frozen_string_literal: true

module Support
  module Users
    class ChecksController < ApplicationController
      include NewUserDraft

      def show
        redirect_to new_support_recruitment_cycle_user_path if new_user_draft.blank?

        @user = User.new(new_user_draft)
      end

      def update
        @user = User.new(new_user_draft.merge(state: "new"))

        if @user.save
          clear_new_user_draft
          redirect_to support_recruitment_cycle_users_path, flash: { success: t(".success") }
        else
          render :show, status: :unprocessable_entity
        end
      end
    end
  end
end
