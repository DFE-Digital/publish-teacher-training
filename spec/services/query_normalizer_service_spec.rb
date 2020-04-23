require "rails_helper"

describe QueryNormalizerService do
  describe ".call" do
    subject { described_class.call(query: query) }

    context "query contains spaces" do
      let(:query) { "boo yah" }
      it { is_expected.to eq("booyah") }
    end

    context "query contains upper case characters" do
      let(:query) { "UpDown" }
      it { is_expected.to eq("updown") }
    end

    context "query contains numbers" do
      let(:query) { "123" }
      it { is_expected.to eq("123") }
    end

    context "query contains unicode characters" do
      let(:query) { "car’s" }
      it { is_expected.to eq("cars") }
    end

    context "query contains URL encoded characters" do
      let(:query) { "cars%20bikes%E2%80%99" }
      it { is_expected.to eq("carsbikes") }
    end

    context "query is nil" do
      let(:query) { nil }
      it { is_expected.to eq("") }
    end

    context "query is ''" do
      let(:query) { "" }
      it { is_expected.to eq("") }
    end

    context "query is only special characters" do
      let(:query) { "%20 ’ " }
      it { is_expected.to eq("") }
    end
  end
end
