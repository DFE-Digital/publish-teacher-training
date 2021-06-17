module MCB
  module Token
    class EncodeService
      class << self
        def call(*args)
          new(*args).call
        end
      end

      def initialize(payload:,
                     secret: nil,
                     algorithm: nil,
                     audience: nil,
                     issuer: nil,
                     subject: nil)
        @payload = payload

        @secret = secret
        @algorithm = algorithm
        @audience = audience
        @issuer = issuer
        @subject = subject
      end

      def call
        JWT.encode(
          data,
          secret,
          algorithm,
        )
      end

    private

      attr_reader :payload, :secret, :algorithm, :audience, :issuer, :subject

      def data
        {
          data: payload,
          **claims,
        }
      end

      def claims
        now = Time.now.to_i
        {
          aud: audience,
          exp: (now + (5 * 60)),
          iat: now,
          iss: issuer,
          sub: subject,
        }
      end
    end
  end
end
