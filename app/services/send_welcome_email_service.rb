class SendWelcomeEmailService
  def initialize(mailer:)
    @mailer = mailer
  end

  def execute(current_user:)
    return if current_user.welcome_email_date_utc

    @mailer.send_welcome_email(first_name: current_user.first_name, email: current_user.email).deliver_now

    current_user.update(
      welcome_email_date_utc: Time.now.utc,
    )
  end
end
