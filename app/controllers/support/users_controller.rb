module Support
  class UsersController < ApplicationController
    def index
      @users = User.order(:last_name).page(params[:page] || 1)
    end

    def show
      @providers = providers.order(:provider_name).page(params[:page] || 1)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to support_users_path
      else
        render :new
      end
    end

    def destroy
      if user.destroy
        redirect_to support_users_path, flash: { success: "User successfully deleted" }
      else
        redirect_to support_users_path, flash: { success: "This user has already been deleted" }
      end
    end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email).merge(state: "new")
    end

    def user
      @user ||= User.find(params[:id])
    end

    def providers
      RecruitmentCycle.current.providers.where(id: user.providers)
    end
  end
end
