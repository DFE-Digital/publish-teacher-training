module Support
  class UsersController < ApplicationController
    def index
      @users = User.order(:last_name).page(params[:page] || 1)
    end

    def show
      @providers = providers.order(:provider_name).page(params[:page] || 1)
    end

  private

    def user
      @user ||= User.find(params[:id])
    end

    def providers
      RecruitmentCycle.current.providers.where(id: user.providers)
    end
  end
end
