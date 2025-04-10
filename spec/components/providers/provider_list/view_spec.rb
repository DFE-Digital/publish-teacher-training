# frozen_string_literal: true

require "rails_helper"

RSpec.describe Providers::ProviderList::View do
  let(:scitt_provider) { create(:accredited_provider, :scitt) }
  let(:lead_school_provider) { create(:provider) }
  let(:university_provider) { create(:accredited_provider, :university) }

  describe "#formatted_accrediting_provider" do
    context "provider is an accredited provider and scitt" do
      it "renders the correct value" do
        expect(described_class.new(provider: scitt_provider).formatted_accrediting_provider).to eq("Yes")
      end
    end

    context "provider is not an accredited provider and lead school" do
      it "renders the correct value" do
        expect(described_class.new(provider: lead_school_provider).formatted_accrediting_provider).to eq("No")
      end
    end

    context "provider is an accredited provider and university" do
      it "renders the correct value" do
        expect(described_class.new(provider: university_provider).formatted_accrediting_provider).to eq("Yes")
      end
    end
  end

  describe "#formatted_provider_type" do
    context "provider is a scitt" do
      it "renders the correct value" do
        expect(described_class.new(provider: scitt_provider).formatted_provider_type).to eq("SCITT")
      end
    end

    context "provider is a lead school" do
      it "renders the correct value" do
        expect(described_class.new(provider: lead_school_provider).formatted_provider_type).to eq("Lead school")
      end
    end

    context "provider is a university" do
      it "renders the correct value" do
        expect(described_class.new(provider: university_provider).formatted_provider_type).to eq("University")
      end
    end
  end
end
