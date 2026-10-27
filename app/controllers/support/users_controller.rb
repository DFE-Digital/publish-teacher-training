# frozen_string_literal: true

module Support
  class UsersController < ApplicationController
    include NewUserDraft

    def index
      recruitment_cycle
      @pagy, @users = pagy(filtered_users)
    end

    def show
      user
    end

    def new
      clear_new_user_draft unless params[:change]
      @user = User.new(new_user_draft)
    end

    def edit
      user
    end

    def create
      @user = User.new(new_user_params.merge(state: "new"))

      if @user.valid?
        stash_new_user(new_user_params)
        redirect_to check_support_recruitment_cycle_users_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if user.update(update_user_params)
        redirect_to support_recruitment_cycle_user_path(params[:recruitment_cycle_year], user), flash: { success: t("support.flash.updated", resource: "User") }
      else
        render :edit
      end
    end

    def delete
      user
    end

    def destroy
      user.destroy!
      redirect_to support_recruitment_cycle_users_path(params[:recruitment_cycle_year]), flash: { success: t("support.flash.deleted", resource: "User") }
    end

  private

    def update_user_params
      params.expect(user: %i[first_name last_name email admin])
    end

    def user
      @user ||= User.find(params[:id])
    end

    def filtered_users
      Support::Filter.call(model_data_scope: User.order(:last_name), filter_params:)
    end

    def filter_params
      @filter_params ||= params.except(:commit, :recruitment_cycle_year).permit(:text_search, :page, :commit, user_type: [])
    end
  end
end
