class GenerateAndSendMagicLinkService
  class << self
    def call(user:)
      new.call(user: user)
    end
  end

  def call(user:)
    generate_magic_link_token(user)

    send_magic_link(user)
  end

private

  def generate_magic_link_token(user)
    user.magic_link_token = SecureRandom.uuid
    user.magic_link_token_sent_at = Time.now.utc
    user.save!
  end

  def send_magic_link(user)
    MagicLinkEmailMailer
      .magic_link_email(user)
      .deliver_later(queue: "mailer")
  end
end
