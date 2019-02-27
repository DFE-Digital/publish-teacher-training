module API
  module V2
    class SessionsController < ApplicationController
      def create
        @current_user.update(
          last_login_date_utc: Time.now.utc,
          first_name: params[:first_name],
          last_name: params[:last_name]
        )

        render jsonapi: @current_user
      end
    end
  end
end
