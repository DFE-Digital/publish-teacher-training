class AuthenticationService
  attr_accessor :encoded_token, :user

  def initialize(logger:)
    @logger = logger
  end

  class << self
    DFE_SIGNIN = "dfe_signin".freeze
    PERSONA = "persona".freeze

    def mode
      Settings.authentication.mode == PERSONA ? PERSONA : DFE_SIGNIN
    end

    def dfe_signin?
      mode == DFE_SIGNIN
    end

    def persona?
      mode == PERSONA
    end
  end

  def execute(encoded_token)
    @encoded_token = encoded_token
    @user = find_user_by_sign_in_user_id || find_user_by_email
    update_user_information if user
    user
  rescue DuplicateUserError => e
    Sentry.capture_exception(e)
    user
  end

private

  attr_reader :logger

  def decoded_token
    @decoded_token ||= Token::DecodeService.call(encoded_token: encoded_token,
                                                 secret: Settings.authentication.secret,
                                                 algorithm: Settings.authentication.algorithm,
                                                 audience: Settings.authentication.audience,
                                                 issuer: Settings.authentication.issuer,
                                                 subject: Settings.authentication.subject)
  end

  def email_from_token
    decoded_token["email"]&.downcase
  end

  def sign_in_user_id_from_token
    decoded_token["sign_in_user_id"]
  end

  def first_name_from_token
    decoded_token["first_name"]
  end

  def last_name_from_token
    decoded_token["last_name"]
  end

  def update_user_information
    update_user_first_name
    update_user_last_name
    update_user_sign_in_id
    update_user_email
  end

  def find_user_by_email
    if email_from_token.blank?
      log_message(:debug, user, "No email in token")
      return
    end

    user = User.find_by("lower(email) = ?", email_from_token)

    if user
      log_message(:info, user, "User found by email address")
    end

    user
  end

  def find_user_by_sign_in_user_id
    if sign_in_user_id_from_token.blank?
      log_message(:debug, user, "No sign_in_user_id in token")
      return
    end

    user = User.find_by(sign_in_user_id: sign_in_user_id_from_token)

    if user
      log_message(:info, user, "User found from sign_in_user_id in token", { sign_in_user_id: sign_in_user_id_from_token })
    end

    user
  end

  def user_email_does_not_match_token?
    user.email&.downcase != email_from_token
  end

  def user_sign_in_id_does_not_match_token?
    return unless user

    user.sign_in_user_id != sign_in_user_id_from_token
  end

  def update_user_email
    return unless user_email_does_not_match_token?

    if (existing_user = find_user_by_email)
      raise DuplicateUserError.new(
        "Duplicate user detected",
        user_id: user.id,
        user_sign_in_user_id: user.sign_in_user_id,
        existing_user_id: existing_user.id,
        existing_user_sign_in_user_id: existing_user.sign_in_user_id,
      )
    else
      log_message(:debug, user, "Updating user email for", { new_email_md5: "MD5:#{obfuscate_email(email_from_token)}" })

      user.update!(email: email_from_token)
    end
  end

  def update_user_sign_in_id
    return unless user_sign_in_id_does_not_match_token?

    user.update!(sign_in_user_id: sign_in_user_id_from_token)
  end

  def update_user_first_name
    if first_name_from_token.blank?
      log_message(:debug, user, "No first name in token")
      return
    end

    user.update!(first_name: first_name_from_token)
  end

  def update_user_last_name
    if last_name_from_token.blank?
      log_message(:debug, user, "No last name in token")
      return
    end

    user.update!(last_name: last_name_from_token)
  end

  def log_safe_user(user)
    user.slice(
      "id",
      "state",
      "first_login_date_utc",
      "last_login_date_utc",
      "sign_in_user_id",
      "welcome_email_date_utc",
      "invite_date_utc",
      "accept_terms_date_utc",
    ).merge("email_md5" => obfuscate_email(user.email))
  end

  def obfuscate_email(email)
    Digest::MD5.hexdigest(email)
  end

  def log_message(level, user, message, extra_attributes = {})
    attributes = extra_attributes
    attributes = attributes.merge(user: log_safe_user(user)) if user

    logger.public_send(level) do
      "#{message} #{attributes} "
    end
  end
end
