class AuthenticationService
  attr_accessor :encoded_token, :user

  def self.call(encoded_token)
    new(encoded_token).call
  end

  def initialize(encoded_token)
    @encoded_token = encoded_token
  end

  def call
    @user = user_by_sign_in_user_id || user_by_email
    update_user_email if user_email_does_not_match_token?
    update_user_sign_in_id if user_sign_in_id_does_not_match_token?

    user
  rescue DuplicateUserError => e
    Raven.capture(e)

    user
  end

private

  def logger
    Rails.logger
  end

  def decoded_token
    @decoded_token ||= JWT.decode(
      encoded_token,
      Settings.authentication.secret,
      Settings.authentication.algorithm,
    )
    (decoded_token_payload, _algorithm) = @decoded_token

    decoded_token_payload
  end

  def email_from_token
    decoded_token["email"]&.downcase
  end

  def sign_in_user_id_from_token
    decoded_token["sign_in_user_id"]
  end

  def user_by_email
    if email_from_token.blank?
      logger.debug("No email in token")
      return
    end

    @user_by_email ||= User.find_by("lower(email) = ?", email_from_token)
    if @user_by_email
      logger.debug {
        "User found by email address " + {
          user: log_safe_user(@user_by_email),
        }.to_s
      }
    end
    @user_by_email
  end

  def user_by_sign_in_user_id
    if sign_in_user_id_from_token.blank?
      logger.debug("No sign_in_user_id in token")
      return
    end

    user = User.find_by(sign_in_user_id: sign_in_user_id_from_token)
    if user
      logger.debug("User found from sign_in_user_id in token " + {
                     sign_in_user_id: sign_in_user_id_from_token,
                     user: log_safe_user(user),
                   }.to_s)
    end
    user
  end

  def update_user_email_needed?
    user_email_does_not_match_token? && !email_in_use_by_another_user?
  end

  def user_email_does_not_match_token?
    return unless user

    user.email&.downcase != email_from_token
  end

  def user_sign_in_id_does_not_match_token?
    return unless user

    user.sign_in_user_id != sign_in_user_id_from_token
  end

  def email_in_use_by_another_user?
    user_by_email.present?
  end

  def update_user_email
    if email_in_use_by_another_user?
      raise DuplicateUserError.new(
        "Duplicate user detected",
        user_id:                       user.id,
        user_sign_in_user_id:          user.sign_in_user_id,
        existing_user_id:              user_by_email.id,
        existing_user_sign_in_user_id: user_by_email.sign_in_user_id,
      )
    else
      logger.debug("Updating user email for " + {
        user: log_safe_user(user),
        new_email_md5: md5_email(email_from_token),
      }.to_s)

      user.update(email: email_from_token)
    end
  end

  def update_user_sign_in_id
    user.update(sign_in_user_id: sign_in_user_id_from_token)
  end

  def log_safe_user(user, reload: false)
    if @log_safe_user.nil? || reload
      @log_safe_user = user.slice(
        "id",
        "state",
        "first_login_date_utc",
        "last_login_date_utc",
        "sign_in_user_id",
        "welcome_email_date_utc",
        "invite_date_utc",
        "accept_terms_date_utc",
      )
      @log_safe_user.merge!(
        Hash[user.slice("email").map { |k, v| [k + "_md5", Digest::MD5.hexdigest(v)] }],
      )
    end
    @log_safe_user
  end

  def md5_email(email)
    "MD5:" + Digest::MD5.hexdigest(email)
  end
end
