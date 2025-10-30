# frozen_string_literal: true

require "rails_helper"

shared_examples "urn uniqueness validation" do
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

    context "when another school site has the same URN" do
      let!(:existing_site) do
        create(:site, provider:, urn: "123456", site_type: :school)
      end

      before do
        params[:urn] = "123456"
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:urn]).to include("URN is in use by another location")
      end
    end

    context "when a study site has the same URN" do
      let!(:existing_study_site) do
        create(:site, provider:, urn: "123456", site_type: :study_site)
      end

      context "and the new site is a school" do
        before do
          params[:urn] = "123456"
          params[:site_type] = :school
        end

        it "is valid (schools and study sites have separate namespaces)" do
          expect(subject).to be_valid
        end
      end
    end

    context "when the same site is being updated" do
      let(:existing_site) do
        create(:site, provider:, urn: "123456", site_type: :school)
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
        create(:site, provider: other_provider, urn: "123456")
      end

      before { params[:urn] = "123456" }

      it "is valid (URN only needs to be unique within provider)" do
        expect(subject).to be_valid
      end
    end

    context "when editing a study site" do
      let!(:existing_study_site) do
        create(:site, provider:, urn: "111111", site_type: :study_site)
      end
      let!(:another_study_site) do
        create(:site, provider:, urn: "123456", site_type: :study_site)
      end
      let(:site) { provider.study_sites.build(site_type: :study_site) }

      before { params[:urn] = "123456" }

      it "is invalid when duplicating another study site URN" do
        expect(subject).not_to be_valid
        expect(subject.errors[:urn]).to include("URN is in use by another location")
      end
    end

    context "when multiple sites have blank URNs" do
      let!(:site_without_urn_a) do
        create(:site, provider:, urn: nil, site_type: :school)
      end
      let!(:site_without_urn_b) do
        create(:site, provider:, urn: "", site_type: :school)
      end

      before { params[:urn] = nil }

      it "is valid (multiple sites can have blank URNs)" do
        expect(subject).to be_valid
      end
    end

    context "when URN has both format and uniqueness errors" do
      let!(:existing_site) do
        create(:site, provider:, urn: "123456", site_type: :school)
      end

      before { params[:urn] = "12345" }

      it "is valid (different URN despite format being valid)" do
        expect(subject).to be_valid
      end
    end

    context "when URN is duplicate and has validation error" do
      let!(:existing_site) do
        create(:site, provider:, urn: "123456", site_type: :school)
      end

      before { params[:urn] = "123456" }

      it "shows uniqueness error" do
        expect(subject).not_to be_valid
        expect(subject.errors[:urn]).to include("URN is in use by another location")
        expect(subject.errors[:urn]).not_to include("URN must be 5 or 6 numbers")
      end
    end

    context "when a discarded site has the same URN" do
      let!(:discarded_site) do
        create(:site, provider:, urn: "123456", site_type: :school).tap(&:discard!)
      end

      before { params[:urn] = "123456" }

      it "is valid (discarded sites don't block URN reuse)" do
        expect(subject).to be_valid
      end
    end

    context "when both discarded and kept sites exist with the same URN" do
      let!(:discarded_site) do
        create(:site, provider:, urn: "123456", site_type: :school).tap(&:discard!)
      end
      let!(:kept_site) do
        create(:site, provider:, urn: "123456", site_type: :school)
      end

      before { params[:urn] = "123456" }

      it "is invalid (kept site still blocks the URN)" do
        expect(subject).not_to be_valid
        expect(subject.errors[:urn]).to include("This school has already been added")
      end
    end

    context "when updating a kept site to match a discarded site's URN" do
      let!(:discarded_site) do
        create(:site, provider:, urn: "999999", site_type: :school).tap(&:discard!)
      end
      let(:existing_kept_site) do
        create(:site, provider:, urn: "123456", site_type: :school)
      end
      let(:site) { existing_kept_site }

      before { params[:urn] = "999999" }

      it "is valid (can reuse URN from discarded site)" do
        expect(subject).to be_valid
      end
    end
  end
end
