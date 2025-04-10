# frozen_string_literal: true

require "rails_helper"

RSpec.describe URNParser do
  subject { described_class.new(urns).call }

  describe "with duplicates" do
    let(:urns) { "123456,123456" }

    it "removes duplicates" do
      expect(subject).to eq(%w[123456])
    end
  end

  describe "with CRNL" do
    let(:urns) { "123456\r\n654321" }

    it "parses all the URNs correctly" do
      expect(subject).to eq(%w[
        123456
        654321
      ])
    end
  end

  describe "with trailing / leading whitespace" do
    let(:urns) { "  123456,  654321   " }

    it "parses all the URNs correctly" do
      expect(subject).to eq(%w[
        123456
        654321
      ])
    end
  end

  describe "with blank lines" do
    let(:urns) { "\n\n123456\n\n654321\n\n" }

    it "parses all the URNs correctly" do
      expect(subject).to eq(%w[
        123456
        654321
      ])
    end
  end

  describe "punctuation that is not a comma" do
    let(:urns) { ")(*+_][,*&^%$£" }

    it "parses all the URNs correctly" do
      expect(subject).to eq(%w[
        )(*+_\]\[
        *&^%$£
      ])
    end
  end
end
