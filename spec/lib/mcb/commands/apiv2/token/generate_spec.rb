require "spec_helper"
require "mcb_helper"

describe "mcb apiv2 token generate" do
  describe "generating a token with a secret" do
    let(:secret) { "sekret" }

    let(:algorithm) { "HS256" }
    let(:audience) { "audience" }
    let(:issuer) { "issuer" }
    let(:subject) { "subject" }

    let(:email) { "user@local" }

    it "returns a plain-text JSON string" do
      result = with_stubbed_stdout do
        $mcb.run(%w[apiv2
                    token
                    generate
                    -S
                    sekret
                    --audience
                    audience
                    --issuer
                    issuer
                    --subject
                    subject
                    user@local])
      end

      encoded_token = result[:stdout]

      payload = { "email" => email }

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
          aud: audience,
          iss: issuer,
          sub: subject,
        },
      )

      (decoded_token_value, _algorithm) = decoded_token

      data = decoded_token_value.with_indifferent_access[:data]

      expect(data).to eq(payload)
    end
  end
end
