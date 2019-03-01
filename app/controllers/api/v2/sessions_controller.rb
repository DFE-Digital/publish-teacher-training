module API
  module V2
    class SessionsController < ApplicationController
      include ValidateJsonapiType

      deserializable_resource :session

      def create
        @current_user.update(
          create_params.merge(
            last_login_date_utc: Time.now.utc
          )
        )

        render jsonapi: @current_user
      end

    private

      def create_params
        validate_jsonapi_type(params, 'sessions')

        params.require(:session).permit(:first_name, :last_name)
      end
    end
  end
end
