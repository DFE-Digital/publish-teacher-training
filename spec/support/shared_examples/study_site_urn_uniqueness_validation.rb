# frozen_string_literal: true

require "rails_helper"

shared_examples "study site urn uniqueness validation" do
  describe "urn uniqueness" do
    context "when URN is blank" do
      before { params[:urn] = "" }

      it "is valid (no uniqueness check for blank URN)" do
        expect(subject).to be_valid
      end
    end

    context "when URN is nil" do
      before { params[:urn] = nil }

      it "is valid (no uniqueness check for nil URN)" do
        expect(subject).to be_valid
      end
    end

    context "when another study site has the same URN" do
      let!(:existing_site) do
        create(:site, provider:, urn: "123456", site_type: :study_site)
      end

      before { params[:urn] = "123456" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:urn]).to include("URN is in use by another location")
      end
    end

    context "when a school has the same URN" do
      let!(:existing_school) do
        create(:site, provider:, urn: "123456", site_type: :school)
      end

      before { params[:urn] = "123456" }

      it "is valid (schools and study sites have separate namespaces)" do
        expect(subject).to be_valid
      end
    end

    context "when the same site is being updated" do
      let(:existing_site) do
        create(:site, provider:, urn: "123456", site_type: :study_site)
      end
      let(:site) { existing_site }

      before do
        params[:urn] = "123456"
        params[:location_name] = "Updated Name"
      end

      it "is valid (same site can keep its own URN)" do
        expect(subject).to be_valid
      end
    end

    context "when a site from a different provider has the same URN" do
      let(:other_provider) { create(:provider) }
      let!(:other_site) do
        create(:site, provider: other_provider, urn: "123456", site_type: :study_site)
      end

      before { params[:urn] = "123456" }

      it "is valid (URN only needs to be unique within provider)" do
        expect(subject).to be_valid
      end
    end

    context "when multiple sites have blank URNs" do
      let!(:site_without_urn_a) do
        create(:site, provider:, urn: nil, site_type: :study_site)
      end
      let!(:site_without_urn_b) do
        create(:site, provider:, urn: "", site_type: :study_site)
      end

      before { params[:urn] = nil }

      it "is valid (multiple sites can have blank URNs)" do
        expect(subject).to be_valid
      end
    end

    context "when URN has both format and uniqueness errors" do
      let!(:existing_site) do
        create(:site, provider:, urn: "123456", site_type: :study_site)
      end

      before { params[:urn] = "12345" }

      it "is valid (different URN despite format being valid)" do
        expect(subject).to be_valid
      end
    end

    context "when URN is duplicate and has validation error" do
      let!(:existing_site) do
        create(:site, provider:, urn: "123456", site_type: :study_site)
      end

      before { params[:urn] = "123456" }

      it "shows uniqueness error" do
        expect(subject).not_to be_valid
        expect(subject.errors[:urn]).to include("URN is in use by another location")
        expect(subject.errors[:urn]).not_to include("URN must be 5 or 6 numbers")
      end
    end
  end
end
