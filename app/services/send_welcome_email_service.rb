class SendWelcomeEmailService
  class MissingFirstNameError < StandardError; end
  class << self
    def call(current_user:)
      new.call(current_user: current_user)
    end
  end

  def call(current_user:)
    return if current_user.welcome_email_date_utc

    # Getting visibility on the missing personalisation first_name issue
    raise MissingFirstNameError, "This user does not have a first name." if current_user.first_name.blank?

    WelcomeEmailMailer
      .send_welcome_email(first_name: current_user.first_name, email: current_user.email)
      .deliver_later

    current_user.update(
      welcome_email_date_utc: Time.now.utc,
    )
  rescue MissingFirstNameError => e
    Sentry.capture_exception(e)
  end
end
