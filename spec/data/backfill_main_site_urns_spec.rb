# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20260410105723_backfill_main_site_urns")

describe BackfillMainSiteUrns do
  def run_migration
    described_class.new.up
  end

  let(:current_cycle) { find_or_create(:recruitment_cycle) }
  let(:previous_cycle) { find_or_create(:recruitment_cycle, :previous) }
  let(:current_provider) { create(:provider, recruitment_cycle: current_cycle) }
  let(:previous_provider) { create(:provider, recruitment_cycle: previous_cycle) }

  context "when exactly one GiasSchool matches by postcode" do
    let!(:gias_school) { create(:gias_school, :open, urn: "123456", postcode: "SW1A 1AA") }
    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "sw1a1aa")
    end

    it "backfills the urn" do
      expect { run_migration }.to change { site.reload.urn }.from(nil).to("123456")
    end

    it "is idempotent" do
      run_migration
      expect { run_migration }.not_to(change { site.reload.urn })
    end

    it "normalizes postcodes regardless of casing and whitespace" do
      site.update_column(:postcode, " sw1a 1aa ")
      run_migration
      expect(site.reload.urn).to eq("123456")
    end
  end

  context "when multiple GiasSchools match by postcode" do
    before do
      create(:gias_school, :open, urn: "111111", postcode: "SW1A 1AA")
      create(:gias_school, :open, urn: "222222", postcode: "SW1A 1AA")
    end

    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "SW1A 1AA")
    end

    it "does not update the urn" do
      expect { run_migration }.not_to(change { site.reload.urn })
    end
  end

  context "when ambiguous postcode is disambiguated by provider ukprn" do
    let(:current_provider) { create(:provider, recruitment_cycle: current_cycle, ukprn: "10000001") }
    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "SW1A 1AA")
    end

    before do
      create(:gias_school, :open, urn: "111111", postcode: "SW1A 1AA", ukprn: "10000001")
      create(:gias_school, :open, urn: "222222", postcode: "SW1A 1AA", ukprn: "10000002")
    end

    it "picks the school sharing the provider's ukprn" do
      expect { run_migration }.to change { site.reload.urn }.from(nil).to("111111")
    end
  end

  context "when ambiguous postcode is disambiguated by location_name" do
    before do
      create(:gias_school, :open, urn: "111111", name: "Hilltop Infant School", postcode: "SS11 8LT", ukprn: "10000003")
      create(:gias_school, :open, urn: "222222", name: "Hilltop Junior School", postcode: "SS11 8LT", ukprn: "10000004")
    end

    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "SS11 8LT", location_name: "Hilltop Infant School")
    end

    it "picks the school whose name matches location_name" do
      expect { run_migration }.to change { site.reload.urn }.from(nil).to("111111")
    end
  end

  context "when ambiguous postcode cannot be disambiguated" do
    before do
      create(:gias_school, :open, urn: "111111", name: "Alpha School", postcode: "SW1A 1AA", ukprn: "10000005")
      create(:gias_school, :open, urn: "222222", name: "Beta School", postcode: "SW1A 1AA", ukprn: "10000006")
    end

    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "SW1A 1AA", location_name: "Main Site")
    end

    it "leaves the urn untouched" do
      expect { run_migration }.not_to(change { site.reload.urn })
    end
  end

  context "when no GiasSchool matches by postcode" do
    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "ZZ9 9ZZ")
    end

    it "does not update the urn" do
      expect { run_migration }.not_to(change { site.reload.urn })
    end
  end

  context "when the matching GiasSchool is closed" do
    before do
      create(:gias_school, :closed, urn: "999999", postcode: "SW1A 1AA")
    end

    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "SW1A 1AA")
    end

    it "does not update the urn" do
      expect { run_migration }.not_to(change { site.reload.urn })
    end
  end

  context "when the site is in a previous recruitment cycle" do
    before { create(:gias_school, :open, urn: "123456", postcode: "SW1A 1AA") }

    let!(:site) do
      create(:site, :main_site, provider: previous_provider, postcode: "SW1A 1AA")
    end

    it "does not touch sites outside the current cycle" do
      expect { run_migration }.not_to(change { site.reload.urn })
    end
  end

  context "when the site already has a urn" do
    before { create(:gias_school, :open, urn: "999999", postcode: "SW1A 1AA") }

    let!(:site) do
      create(:site, provider: current_provider, postcode: "SW1A 1AA", urn: "555555")
    end

    it "does not overwrite the existing urn" do
      expect { run_migration }.not_to(change { site.reload.urn })
    end
  end

  context "when the site is a study site" do
    before { create(:gias_school, :open, urn: "123456", postcode: "SW1A 1AA") }

    let!(:site) do
      create(:site, :study_site, provider: current_provider, postcode: "SW1A 1AA", urn: nil)
    end

    it "does not update study sites" do
      expect { run_migration }.not_to(change { site.reload.urn })
    end
  end

  context "when the site has an empty-string urn" do
    before { create(:gias_school, :open, urn: "123456", postcode: "SW1A 1AA") }

    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "SW1A 1AA", urn: "")
    end

    it "backfills the urn" do
      expect { run_migration }.to change { site.reload.urn }.from("").to("123456")
    end
  end

  context "when the site has a whitespace-only urn" do
    before { create(:gias_school, :open, urn: "123456", postcode: "SW1A 1AA") }

    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "SW1A 1AA", urn: " ")
    end

    it "backfills the urn" do
      expect { run_migration }.to change { site.reload.urn }.from(" ").to("123456")
    end
  end

  context "when the site is soft-deleted" do
    before { create(:gias_school, :open, urn: "123456", postcode: "SW1A 1AA") }

    let!(:site) do
      create(:site, :main_site, provider: current_provider, postcode: "SW1A 1AA", discarded_at: Time.current)
    end

    it "does not update discarded sites" do
      expect { run_migration }.not_to(change { site.reload.urn })
    end
  end

  describe "#down" do
    it "is irreversible" do
      expect { described_class.new.down }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
