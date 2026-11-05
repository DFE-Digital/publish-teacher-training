# frozen_string_literal: true

require "rails_helper"

RSpec.describe APIKeySecret do
  let(:secret) { "#{described_class::PREFIX}#{'a' * 64}" }

  describe ".present_in?" do
    it "finds a secret through repeated percent-encoding" do
      [
        secret,
        "before #{secret} after",
        secret.sub("_", "%5F"),
        secret.sub("p", "%2570"),
        secret.sub("p", "%252570"),
      ].each do |text|
        expect(described_class.present_in?(text)).to be(true), text
      end
    end

    it "does not find one in text that is not key-shaped, even with invalid bytes" do
      ["", "ptt_not-a-real-key", "ptt_#{'a' * 63}", "100%25", "\xFF"].each do |text|
        expect(described_class.present_in?(text)).to be(false), text
      end
    end
  end
end
