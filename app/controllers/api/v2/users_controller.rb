module API
  module V2
    class UsersController < ApplicationController
      def show
        user = User.find(params[:id])
        authorize user

        render jsonapi: user,
               class: { User: API::V2::UserSerializable,
                        Provider: API::V2::ProviderSerializable },
               include: params[:includes]
      end
    end
  end
end
