require "spec_helper"
require "mcb_helper"

describe "mcb apiv2 token generate" do
  describe "generating a token with a secret" do
    it "returns a plain-text JSON string" do
      result = with_stubbed_stdout do
        $mcb.run(%w[apiv2 token generate -S sekret user@local])
      end
      result = result[:stdout]

      payload = { "email" => "user@local" }

      decoded_token = JWT::DecodeService.call(encoded_token: result, secret: "sekret", algorithm: "HS256")

      expect(decoded_token).to eq(payload)
    end
  end
end
