require "rails_helper"

describe FindConstraint do
  let(:request) {
    double(
      :request,
      host:,
    )
  }
  let(:find_temp_url) { "find_temp_url" }
  let(:host) { "find_temp_url" }

  subject {
    described_class.new.matches?(request)
  }

  describe "#matched?" do
    before do
      Settings.find_temp_url = find_temp_url
    end

    context "Settings.find_temp_url is same as host" do
      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "Settings.find_temp_url is different to host" do
      let(:host) { "find_different_url" }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end

    context "Settings.find_temp_url is nil" do
      let(:find_temp_url) { nil }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end
end
