class SendWelcomeEmailService
  class << self
    def call(current_user:)
      new.call(current_user: current_user)
    end
  end

  def call(current_user:)
    return if current_user.welcome_email_date_utc

    WelcomeEmailMailer.send_welcome_email(first_name: current_user.first_name, email: current_user.email).deliver_now

    current_user.update(
      welcome_email_date_utc: Time.now.utc,
    )
  end
end
