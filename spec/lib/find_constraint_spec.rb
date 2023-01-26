require "rails_helper"

describe FindConstraint do
  let(:request) {
    double(
      :request,
      host:,
    )
  }
  let(:find_url) { "find_url" }
  let(:host) { "find_url" }

  subject {
    described_class.new.matches?(request)
  }

  describe "#matched?" do
    before do
      Settings.find_url = find_url
    end

    context "Settings.find_url is same as host" do
      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "Settings.find_url is different to host" do
      let(:host) { "find_different_url" }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end

    context "Review environment" do
      let(:host) { "find-pr-123" }

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "Settings.find_url is nil" do
      let(:find_url) { nil }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end
end
