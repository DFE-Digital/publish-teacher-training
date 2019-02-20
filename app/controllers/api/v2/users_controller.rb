module API
  module V2
    class UsersController < ApplicationController
      def show
        @user = User.find(params[:id])
        authorize @user

        render jsonapi: @user,
               class: SERIALIZABLE_CLASSES
      end
    end
  end
end
