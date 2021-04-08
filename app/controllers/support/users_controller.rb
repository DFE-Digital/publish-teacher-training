module Support
  class UsersController < ApplicationController

    def index
      @users = User.order(:last_name).page(params[:page] || 1)
    end

    def show
      @user = User.find(params[:id])
    end

  end
end
