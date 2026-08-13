# frozen_string_literal: true

require "rails_helper"

describe ProviderCodeGenerator do
  # A code is a random letter followed by the sequence number, so ruling out
  # every letter but Z leaves "Z30" as the only code that can be generated.
  let(:all_codes_but_z30) { ("A".."Y").map { |letter| "#{letter}30" } }

  before do
    allow(Provider).to receive(:pluck).with(:provider_code).and_return([])
  end

  describe "#call" do
    it "generates a code from the sequence number" do
      expect(described_class.new(30).call).to match(/\A[A-Z]30\z/)
    end

    it "does not generate a code given to avoid" do
      codes = Array.new(10) { described_class.new(30).call(avoid: all_codes_but_z30) }

      expect(codes.uniq).to eq(%w[Z30])
    end

    it "does not generate a code that a provider already has" do
      allow(Provider).to receive(:pluck).with(:provider_code).and_return(all_codes_but_z30)

      codes = Array.new(10) { described_class.new(30).call }

      expect(codes.uniq).to eq(%w[Z30])
    end
  end
end
