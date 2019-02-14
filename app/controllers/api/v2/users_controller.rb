module Api
  module V2
    class UsersController < ApplicationController
      def index
        render jsonapi: User.all, class: { User: API::V2::UserSerializable }
      end
    end
  end
end
