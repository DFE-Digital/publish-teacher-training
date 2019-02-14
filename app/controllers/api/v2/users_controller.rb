module API
  module V2
    class UsersController < ApplicationController
      def index
        render jsonapi: User.all,
               class: SERIALIZABLE_CLASSES
      end
    end
  end
end
