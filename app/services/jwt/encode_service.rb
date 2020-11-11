module JWT
  class EncodeService
    class << self
      def call(*args)
        new(*args).call
      end
    end

    def initialize(payload:,
      secret: Settings.authentication.secret,
      algorithm: Settings.authentication.algorithm)
      @payload = payload
      @secret = secret
      @algorithm = algorithm
    end

    def call
      JWT.encode(
        data,
        secret,
        algorithm,
      )
    end

  private

    attr_reader :payload, :secret, :algorithm

    def data
      {
        data: payload,
        **claims,
      }
    end

    def claims
      now = Time.zone.now
      {
        aud: Settings.authentication.audience,
        exp: (now + 5.minutes).to_i,
        iat: now.to_i,
        iss: Settings.authentication.issuer,
        sub: Settings.authentication.subject,
      }
    end
  end
end
