require "rails_helper"

RSpec.describe DataHub::RegisterSchoolImporter::ProviderResolver do
  subject { described_class.new(recruitment_cycle, parser) }

  let(:recruitment_cycle) { create(:recruitment_cycle) }
  let(:parser) { instance_double(DataHub::RegisterSchoolImporter::RowParser) }

  describe "#resolve" do
    context "when provider_code is present and matches a provider" do
      let!(:provider) { create(:provider, recruitment_cycle: recruitment_cycle, provider_code: "BU4") }

      before do
        allow(parser).to receive(:provider_code).and_return("BU4")
      end

      it "returns the matching provider" do
        expect(subject.resolve).to eq(provider)
      end
    end

    context "when provider_code is nil" do
      before do
        allow(parser).to receive(:provider_code).and_return(nil)
      end

      it "returns nil" do
        expect(subject.resolve).to be_nil
      end
    end

    context "when no provider matches the provider_code" do
      before do
        allow(parser).to receive(:provider_code).and_return("NONEXISTING")
      end

      it "returns nil" do
        expect(subject.resolve).to be_nil
      end
    end
  end
end
