module NotificationService
  class UnrecognisedEmail
    include ServicePattern

    def initialize(email:)
      @email = email
    end

    def call
      EmailUnrecognisedMailer
        .email_unrecognised(email)
        .deliver_later
    end

  private

    attr_reader :email
  end
end
