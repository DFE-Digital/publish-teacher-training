class AuthenticationService
  class DuplicateUserError < StandardError
    def initialize(message, user_id:, user_sign_in_user_id:,
                   existing_user_id:, existing_user_sign_in_user_id:)
      @user_id                       = user_id
      @user_sign_in_user_id          = user_sign_in_user_id
      @existing_user_id              = existing_user_id
      @existing_user_sign_in_user_id = existing_user_sign_in_user_id

      super(message)
    end
  end
end
