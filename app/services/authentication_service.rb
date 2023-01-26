# frozen_string_literal: true

class AuthenticationService
  attr_accessor :encoded_token, :user

  def initialize(logger:)
    @logger = logger
  end

  class << self
    DFE_SIGNIN = 'dfe_signin'
    PERSONA = 'persona'
    MAGIC_LINK = 'magic_link'

    def mode
      case Settings.authentication.mode
      when MAGIC_LINK
        MAGIC_LINK
      when PERSONA
        PERSONA
      else
        DFE_SIGNIN
      end
    end

    def dfe_signin?
      mode == DFE_SIGNIN
    end

    def magic_link?
      mode == MAGIC_LINK
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
  end

private

  attr_reader :logger

  def decoded_token
    @decoded_token ||= Token::DecodeService.call(
      encoded_token:,
      secret: Settings.authentication.secret,
      algorithm: Settings.authentication.algorithm,
      audience: Settings.authentication.audience,
      issuer: Settings.authentication.issuer,
      subject: Settings.authentication.subject
    )
  end

  def email_from_token
    decoded_token['email']&.downcase
  end

  def sign_in_user_id_from_token
    decoded_token['sign_in_user_id']
  end

  def first_name_from_token
    decoded_token['first_name']
  end

  def last_name_from_token
    decoded_token['last_name']
  end

  def update_user_information
    update_user_first_name
    update_user_last_name
    update_user_sign_in_id
    update_user_email
    user.save!
  end

  def find_user_by_email
    if email_from_token.blank?
      log_message(:debug, user, 'No email in token')
      return
    end

    if (user = User.find_by('lower(email) = ?', email_from_token))
      log_message(:info, user, 'User found by email address')
    end

    user
  end

  def find_user_by_sign_in_user_id
    if sign_in_user_id_from_token.blank?
      log_message(:debug, user, 'No sign_in_user_id in token')
      return
    end

    if (user = User.find_by(sign_in_user_id: sign_in_user_id_from_token))
      log_message(:info, user, 'User found from sign_in_user_id in token', { sign_in_user_id: sign_in_user_id_from_token })
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

    if (duplicate_user = find_user_by_email)
      # Change: bob@gmail.com => bob_1634828853_gmail.com@example.com
      new_email = "#{duplicate_user.email.gsub(/@/, "_#{Time.now.to_i}_")}@example.com"

      duplicate_user.update!(email: new_email)
    end

    log_message(:debug, user, 'Updating user email for', { new_email_md5: "MD5:#{obfuscate_email(email_from_token)}" })
    user.email = email_from_token
  end

  def update_user_sign_in_id
    return unless user_sign_in_id_does_not_match_token?

    user.sign_in_user_id = sign_in_user_id_from_token
  end

  def update_user_first_name
    if first_name_from_token.blank?
      log_message(:debug, user, 'No first name in token')
      return
    end

    user.first_name = first_name_from_token
  end

  def update_user_last_name
    if last_name_from_token.blank?
      log_message(:debug, user, 'No last name in token')
      return
    end

    user.last_name = last_name_from_token
  end

  def log_safe_user(user)
    user.slice(
      'id',
      'state',
      'first_login_date_utc',
      'last_login_date_utc',
      'sign_in_user_id',
      'welcome_email_date_utc',
      'invite_date_utc',
      'accept_terms_date_utc'
    ).merge('email_md5' => obfuscate_email(user.email))
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
