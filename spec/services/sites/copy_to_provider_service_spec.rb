# frozen_string_literal: true

require "rails_helper"

describe Sites::CopyToProviderService do
  describe "#execute" do
    let(:site) { build(:site, :school) }
    let(:provider) { create(:provider, sites: [site]) }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }
    let(:next_provider) do
      create(
        :provider,
        sites: [],
        study_sites: [],
        provider_code: provider.provider_code,
        recruitment_cycle: next_recruitment_cycle,
      )
    end

    let(:service) { described_class.new }

    context "basic copy" do
      it "makes a copy of the site in the new provider" do
        result = service.execute(site: site, new_provider: next_provider)

        next_site = next_provider.reload.sites.find_by(code: site.code)
        expect(next_site).not_to be_nil
        expect(result.success?).to be(true)
        expect(result.site).to eq(next_site)
        expect(result.error_message).to be_nil
      end

      it "leaves the existing site alone" do
        service.execute(site: site, new_provider: next_provider)
        expect(provider.reload.sites).to eq [site]
      end
    end

    context "the site already exists in the new provider" do
      let!(:next_site) do
        create(
          :site,
          code: site.code,
          provider: next_provider,
        )
      end

      it "does not make a copy of the site and returns an error result" do
        result = service.execute(site: site, new_provider: next_provider)
        expect(next_provider.reload.sites.count).to eq(1)
        expect(result.success?).to be(false)
        expect(result.site).to be_nil
        expect(result.error_message).to match(/already exists/)
      end
    end

    context "the site is invalid" do
      before do
        provider
        site.update_columns address1: ""
        site.update_columns town: ""
        site.update_columns postcode: ""
        site.update_columns location_name: ""
      end

      it "still copies the site (save is forced)" do
        result = service.execute(site: site, new_provider: next_provider)
        next_site = next_provider.reload.sites.find_by(code: site.code)
        expect(next_site).not_to be_nil
        expect(result.success?).to be(true)
        expect(result.site).to eq(next_site)
      end
    end

    context "the site is a study site" do
      let(:site) { build(:site, :study_site) }
      let(:provider) { create(:provider, study_sites: [site]) }

      it "sets the site type to study site" do
        service.execute(site: site, new_provider: next_provider)
        next_site = next_provider.reload.study_sites.find_by(code: site.code)
        expect(next_site.site_type).to eq("study_site")
      end
    end

    context "assigned code is provided" do
      let(:assigned_code) { "NEWCODE123" }

      it "assigns the given code to the new site" do
        result = service.execute(site: site, new_provider: next_provider, assigned_code: assigned_code)
        expect(result.site.code).to eq(assigned_code)
      end
    end

    context "calls to error handler" do
      let(:site_duplicate) { site.dup }

      before do
        allow(site).to receive(:dup).and_return(site_duplicate)
        allow(site_duplicate).to receive(:save!).and_raise(StandardError.new("Some error"))
      end

      it "returns error result when save throws" do
        result = service.execute(site:, new_provider: next_provider)
        expect(result.success?).to be false
        expect(result.site).to be_nil
        expect(result.error_message).to eq("Some error")
      end
    end

    context "uuid and geocoding" do
      it "sets a new uuid and disables geocoding for new site" do
        result = service.execute(site: site, new_provider: next_provider)
        expect(result.site.uuid).not_to eq(site.uuid)
        expect(result.site.skip_geocoding).to be(true)
      end
    end
  end
end
