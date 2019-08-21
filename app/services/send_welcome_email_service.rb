class SendWelcomeEmailService
  def initialize(mailer:)
    @mailer = mailer
  end

  def execute(current_user:)
    return if current_user.first_login_date_utc

    time_now = Time.now.utc

    current_user.update(
      first_login_date_utc: time_now,
      welcome_email_date_utc: time_now
    )

    @mailer.send_welcome_email(first_name: current_user.first_name, email: current_user.email).deliver_now
  end
end
