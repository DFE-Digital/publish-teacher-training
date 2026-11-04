# frozen_string_literal: true

module APIKeys
  class Creator
    include ServicePattern

    def initialize(user:, name:)
      @user = user
      @secret = "#{APIKey::SECRET_PREFIX}#{SecureRandom.hex(32)}"
      @api_key = APIKey.new(
        name:,
        key_digest: APIKey.digest(secret),
        prefix: secret.first(APIKey::DISPLAY_PREFIX_LENGTH),
      )
    end

    def call
      User.transaction do
        api_key.user = User.lock.find(user.id)
        api_key.secret = secret if api_key.save
      end

      api_key
    end

  private

    attr_reader :user, :secret, :api_key
  end
end
