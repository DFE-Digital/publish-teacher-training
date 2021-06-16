require "rails_helper"

describe Token::DecodeService do
  let(:email) { "bat@localhost" }
  let(:payload) { { "email" => email } }

  let(:encode_service_secret) do
    Settings.authentication.secret
  end
  let(:encode_service_algorithm) do
    Settings.authentication.algorithm
  end
  let(:encode_service_audience) do
    Settings.authentication.audience
  end
  let(:encode_service_issuer) do
    Settings.authentication.issuer
  end
  let(:encode_service_subject) do
    Settings.authentication.subject
  end

  let(:encoded_token) do
    build_jwt(:apiv2,
              payload: payload,
              secret: encode_service_secret,
              algorithm: encode_service_algorithm,
              audience: encode_service_audience,
              issuer: encode_service_issuer,
              subject: encode_service_subject)
  end

  let(:now) { Time.zone.now }

  subject do
    described_class.call(encoded_token: encoded_token,
                         secret: Settings.authentication.secret,
                         algorithm: Settings.authentication.algorithm,
                         audience: Settings.authentication.audience,
                         issuer: Settings.authentication.issuer,
                         subject: Settings.authentication.subject)
  end

  describe "#call" do
    before do
      allow(Time).to receive(:zone)
        .and_return(OpenStruct.new(now: now))
    end

    it "token values are equal" do
      expect(subject).to match(payload)
    end

    context "mismatch" do
      shared_examples "mismatch" do |option, exception, value = option|
        context "#{option} settings" do
          let("encode_service_#{option}".to_sym) { value.to_s }

          it "raises an exception" do
            expect { subject }.to raise_exception exception
          end
        end
      end

      include_examples "mismatch", :secret, JWT::VerificationError
      include_examples "mismatch", :algorithm, JWT::IncorrectAlgorithm, "HS512"
      include_examples "mismatch", :audience, JWT::InvalidAudError
      include_examples "mismatch", :issuer, JWT::InvalidIssuerError
      include_examples "mismatch", :subject, JWT::InvalidSubError
    end

    context "expired token" do
      let(:now) { Time.zone.now - (5.minutes + 6.seconds) }

      it "raises an exception" do
        expect { subject }.to raise_exception JWT::ExpiredSignature
      end
    end
  end
end
