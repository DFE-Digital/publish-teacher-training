require "rails_helper"

describe JWT::DecodeService do
  let(:email) { "bat@localhost" }
  let(:payload) { { "email" => email } }

  let(:encode_service_secret) { nil }
  let(:encode_service_algorithm) { nil }
  let(:encode_service_audience) { nil }
  let(:encode_service_issuer) { nil }
  let(:encode_service_subject) { nil }

  let(:encoded_token) do
    JWT::DecodeService.encode(
      payload: payload,
      secret: encode_service_secret,
      algorithm: encode_service_algorithm,
      audience: encode_service_audience,
      issuer: encode_service_issuer,
      subject: encode_service_subject,
  )
  end

  let(:now) { Time.zone.now }

  subject do
    described_class.call(encoded_token: encoded_token)
  end

  describe "#call" do
    before :each do
      allow(Time).to receive(:zone)
        .and_return(OpenStruct.new(now: now))
    end

    it "token values are equal" do
      expect(subject).to match(payload)
    end

    describe "mismatch" do
      shared_examples "mismatch" do |option, exception, value = option|
        context "#{option} settings" do
          let("encode_service_#{option}".to_sym) { value.to_s }
          it "raised exception" do
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

    describe "expired token" do
      let(:now) { Time.zone.now - (5.minutes + 1.second) }

      it "raised exception" do
        expect { subject }.to_not raise_exception JWT::ExpiredSignature
      end
    end
  end
end
