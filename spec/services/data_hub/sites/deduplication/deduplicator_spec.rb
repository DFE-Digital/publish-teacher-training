# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Sites::Deduplication::Deduplicator do
  let(:deduplicator_class) { described_class }

  def summary_for(outcome)
    DataHub::Sites::Deduplication::SummaryBuilder.new(outcome).short_summary
  end

  describe "#call" do
    it "reassigns site statuses to the primary site and discards duplicates" do
      provider = create(:provider)
      primary = create(:site, provider:, location_name: "Example School", postcode: "SW1A 1AA", urn: "12345")
      duplicate = create(:site, provider:, location_name: "Example School", postcode: "SW1A 1AA", urn: "12345")

      primary_course = create(:course, provider:)
      create(:site_status, site: primary, course: primary_course, status: "running", publish: "Y", vac_status: "F")

      duplicate_course = create(:course, provider:)
      duplicate_status = create(:site_status, site: duplicate, course: duplicate_course, status: "new_status", publish: "N", vac_status: "")

      outcome = deduplicator_class.new(site_scope: Site.where(id: [primary.id, duplicate.id]), dry_run: false).call
      summary = summary_for(outcome)

      expect(duplicate_status.reload.site).to eq(primary)
      expect(duplicate.reload).to be_discarded

      expect(summary[:duplicate_groups_processed]).to eq(1)
      expect(summary[:duplicate_sites_discarded]).to eq(1)
      expect(summary[:site_statuses_reassigned]).to eq(1)
    end

    it "merges duplicate site statuses for the same course preferring the best values" do
      provider = create(:provider)
      primary = create(:site, provider:, location_name: "Shared School", postcode: "BN1 1AA", urn: "77777")
      duplicate = create(:site, provider:, location_name: "Shared School", postcode: "BN1 1AA", urn: "77777")
      course = create(:course, provider:, study_mode: :full_time_or_part_time)

      existing_status = create(:site_status, site: primary, course:, status: "new_status", publish: "N", vac_status: "")
      redundant_status = create(:site_status, site: duplicate, course:, status: "running", publish: "Y", vac_status: "B")

      outcome = deduplicator_class.new(site_scope: Site.where(id: [primary.id, duplicate.id]), dry_run: false).call
      summary = summary_for(outcome)

      expect { redundant_status.reload }.to raise_error(ActiveRecord::RecordNotFound)

      existing_status.reload

      expect(existing_status.status).to eq("running")
      expect(existing_status.publish).to eq("published")
      expect(existing_status.vac_status).to eq("no_vacancies")

      expect(summary[:site_statuses_merged]).to eq(1)
      expect(summary[:site_statuses_removed]).to eq(1)
    end

    it "does not mutate data when run in dry-run mode but reports planned changes" do
      provider = create(:provider)
      primary = create(:site, provider:, location_name: "Dry School", postcode: "LS1 1UR", urn: "88888")
      duplicate = create(:site, provider:, location_name: "Dry School", postcode: "LS1 1UR", urn: "88888")

      create(:site_status, site: primary, course: create(:course, provider:), status: "running", publish: "N", vac_status: "F")

      course = create(:course, provider:)
      duplicate_status = create(:site_status, site: duplicate, course:, status: "running", publish: "Y", vac_status: "F")

      outcome = deduplicator_class.new(site_scope: Site.where(id: [primary.id, duplicate.id]), dry_run: true).call
      summary = summary_for(outcome)

      expect(duplicate.reload).not_to be_discarded
      expect(duplicate_status.reload.site).to eq(duplicate)
      expect(summary[:dry_run]).to eq(true)
      expect(summary[:site_statuses_reassigned]).to eq(1)
      expect(summary[:duplicate_sites_discarded]).to eq(1)
    end

    it "skips duplicates when sites are missing a URN" do
      provider = create(:provider)
      primary = create(:site, provider:, urn: nil, location_name: "No URN A", postcode: "SW1A 1AA")
      duplicate = create(:site, provider:, urn: nil, location_name: "No URN B", postcode: "SW1A 1AA")
      course = create(:course, provider:)
      status = create(:site_status, site: duplicate, course:, status: "running", publish: "Y", vac_status: "F")

      outcome = deduplicator_class.new(site_scope: Site.where(id: [primary.id, duplicate.id]), dry_run: false).call
      summary = summary_for(outcome)

      expect(outcome.groups).to be_empty
      expect(summary[:duplicate_groups_processed]).to eq(0)
      expect(status.reload.site).to eq(duplicate)
      expect(primary.reload.discarded?).to be(false)
      expect(duplicate.reload.discarded?).to be(false)
    end

    it "ignores study site duplicates" do
      provider = create(:provider)
      primary = create(:site, :study_site, provider:, location_name: "Placement", postcode: "EC1A 1BB", urn: "99001")
      duplicate = build(:site, :study_site, provider:, location_name: "Placement", postcode: "EC1A 1BB", urn: "99001")
      duplicate.save(validate: false) # bypass name uniqueness validation
      course = create(:course, provider:)
      placement = create(:study_site_placement, course:, site: duplicate)

      outcome = deduplicator_class.new(site_scope: Site.where(id: [primary.id, duplicate.id]), dry_run: false).call

      expect(outcome.groups).to be_empty
      expect(placement.reload.site).to eq(duplicate)
      expect(primary.reload.discarded?).to be(false)
      expect(duplicate.reload.discarded?).to be(false)
    end
  end
end
