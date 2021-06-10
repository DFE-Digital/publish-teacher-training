module Token
  class DecodeService
    include ServicePattern

    def initialize(encoded_token:,
                   secret:,
                   algorithm:,
                   audience:,
                   issuer:,
                   subject:)

      @encoded_token = encoded_token

      @secret = secret
      @algorithm = algorithm
      @audience = audience
      @issuer = issuer
      @subject = subject
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

    attr_reader :encoded_token, :secret, :algorithm, :audience, :issuer, :subject

    def claims
      @claims ||= {
        aud: audience,
        iss: issuer,
        sub: subject,
      }
    end
  end
end
