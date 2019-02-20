module API
  module V2
    class UsersController < ApplicationController
      def show
        user = User.find(params[:id])
        authorize user

        render jsonapi: user,
               class: { User: API::V2::UserSerializable },
               include: params[:includes]
      end
    end
  end
end
