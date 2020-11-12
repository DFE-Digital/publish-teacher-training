module JWT
  class DecodeService
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

        @secret = secret || Settings.authentication.secret
        @algorithm = algorithm || Settings.authentication.algorithm
        @audience = audience || Settings.authentication.audience
        @issuer = issuer || Settings.authentication.issuer
        @subject = subject || Settings.authentication.subject
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
        now = Time.zone.now
        {
          aud: audience,
          exp: (now + 5.minutes).to_i,
          iat: now.to_i,
          iss: issuer,
          sub: subject,
        }
      end
    end
    class << self
      def call(*args)
        new(*args).call
      end

      def encode(*args)
        EncodeService.call(*args)
      end
    end

    def initialize(encoded_token:,
      secret: nil,
      algorithm: nil)
      @encoded_token = encoded_token
      @secret = secret || Settings.authentication.secret
      @algorithm = algorithm || Settings.authentication.algorithm
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


    private_constant :EncodeService

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
