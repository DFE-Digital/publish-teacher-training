# frozen_string_literal: true

module APIKeys
  class Creator
    include ServicePattern

    def initialize(email:, name:)
      @secret = "#{APIKey::SECRET_PREFIX}#{SecureRandom.hex(32)}"
      @api_key = APIKey.new(
        email:,
        name:,
        key_digest: APIKey.digest(secret),
        prefix: secret.first(APIKey::DISPLAY_PREFIX_LENGTH),
      )
    end

    def call
      APIKey.transaction do
        APIKey.lock_email(api_key.email)
        api_key.secret = secret if api_key.save
      end

      api_key
    end

  private

    attr_reader :secret, :api_key
  end
end
