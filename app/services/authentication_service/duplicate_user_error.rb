class AuthenticationService
  class DuplicateUserError < StandardError
    def initialize(message, user_id:, user_sign_in_user_id:,
                   existing_user_id:, existing_user_sign_in_user_id:)
      @user_id                       = user_id
      @user_sign_in_user_id          = user_sign_in_user_id
      @existing_user_id              = existing_user_id
      @existing_user_sign_in_user_id = existing_user_sign_in_user_id

      message += <<~DEBUG_INFO.insert(0, "\n")
        user_id: #{@user_id},
        user_sign_in_user_id: #{@user_sign_in_user_id},
        existing_user_id: #{@existing_user_id},
        existing_user_sign_in_user_id: #{@existing_user_sign_in_user_id}
      DEBUG_INFO

      super(message)
    end
  end
end
