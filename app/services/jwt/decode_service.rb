module JWT
  class DecodeService
    class << self
      def call(*args)
        new(*args).call
      end
    end

    def initialize(encoded_token:,
      secret: Settings.authentication.secret,
      algorithm: Settings.authentication.algorithm)
      @encoded_token = encoded_token
      @secret = secret
      @algorithm = algorithm
    end

    def call
      decoded_token = JWT.decode(
        encoded_token,
        secret,
        true,
        {
            algorithm: algorithm,
            verify_iss: true,
            verify_aud: true,
            verify_sub: true,
            verify_iat: true,
            exp_leeway: 6.seconds.to_i,
            **claims,
        },
      )

      (payload, _algorithm) = decoded_token

      payload.with_indifferent_access[:data]
    end

  private

    attr_reader :encoded_token, :secret, :algorithm

    def claims
      @claims ||= {
        aud: Settings.authentication.audience,
        iss: Settings.authentication.issuer,
        sub: Settings.authentication.subject,
      }
    end
  end
end
