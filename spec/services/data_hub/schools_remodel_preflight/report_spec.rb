# frozen_string_literal: true

require "rails_helper"

describe DataHub::SchoolsRemodelPreflight::Report do
  subject(:report) { described_class.new(recruitment_cycle_year: cycle.year).call }

  let(:cycle) { create(:recruitment_cycle, year: "2026") }
  let(:provider) { create(:provider, recruitment_cycle: cycle) }
  let(:gias_school) { create(:gias_school) }

  # The invariant the picker migration rests on: provider_school.uuid is copied
  # from site.uuid by both the dual-write and the schools backfill.
  def paired_school(site_code: "A", urn: gias_school.urn)
    uuid = SecureRandom.uuid
    site = create(:site, provider:, uuid:, code: site_code, urn:)
    provider_school = create(:provider_school, provider:, gias_school:, site_code:, uuid:)
    [site, provider_school]
  end

  context "when every school is paired" do
    before { paired_school }

    it "reports nothing" do
      expect(report.orphan_provider_schools).to be_empty
      expect(report.unmapped_sites).to be_empty
    end

    it "is not blocking" do
      expect(report).not_to be_blocking
    end
  end

  describe "orphan provider_schools (PF1)" do
    it "reports a provider_school whose site was discarded" do
      site, provider_school = paired_school
      site.discard!

      expect(report.orphan_provider_schools.map { |row| row["provider_school_id"] })
        .to contain_exactly(provider_school.id)
    end

    it "reports a provider_school with no site at all" do
      provider_school = create(:provider_school, provider:, gias_school:, site_code: "Z")

      expect(report.orphan_provider_schools.map { |row| row["provider_school_id"] })
        .to contain_exactly(provider_school.id)
    end

    it "includes the provider code and school name so the rows are actionable" do
      create(:provider_school, provider:, gias_school:, site_code: "Z")

      row = report.orphan_provider_schools.first
      expect(row["provider_code"]).to eq(provider.provider_code)
      expect(row["name"]).to eq(gias_school.name)
    end

    it "is blocking" do
      create(:provider_school, provider:, gias_school:, site_code: "Z")

      expect(report).to be_blocking
    end

    it "does not accept a study site as the backing record" do
      uuid = SecureRandom.uuid
      create(:site, :study_site, provider:, uuid:, code: "B")
      provider_school = create(:provider_school, provider:, gias_school:, site_code: "B", uuid:)

      expect(report.orphan_provider_schools.map { |row| row["provider_school_id"] })
        .to contain_exactly(provider_school.id)
    end
  end

  describe "unmapped sites (PF2)" do
    it "reports a kept school site with no provider_school" do
      site = create(:site, provider:, code: "C", urn: gias_school.urn)

      expect(report.unmapped_sites.map { |row| row["site_id"] }).to contain_exactly(site.id)
    end

    it "ignores discarded sites" do
      create(:site, provider:, code: "C", urn: gias_school.urn).discard!

      expect(report.unmapped_sites).to be_empty
    end

    it "ignores study sites" do
      create(:site, :study_site, provider:, code: "C")

      expect(report.unmapped_sites).to be_empty
    end

    it "does not block — these schools simply would not appear in the picker" do
      create(:site, provider:, code: "C", urn: gias_school.urn)

      expect(report).not_to be_blocking
    end
  end

  describe "unmapped attachments (PF3)" do
    let(:course) { create(:course, provider:) }

    it "reports a running attachment with no course_school row" do
      site, = paired_school
      create(:site_status, :running, :published, course:, site:)

      expect(report.unmapped_attachments.map { |row| row["course_id"] }).to contain_exactly(course.id)
    end

    it "ignores an attachment that has a course_school row" do
      site, provider_school = paired_school
      create(:site_status, :running, :published, course:, site:)
      create(:course_school, course:, gias_school:, provider_school:)

      expect(report.unmapped_attachments).to be_empty
    end

    it "ignores suspended attachments, which the picker never rendered" do
      site, = paired_school
      create(:site_status, :suspended, course:, site:)

      expect(report.unmapped_attachments).to be_empty
    end
  end

  describe "scoping" do
    it "ignores providers in other recruitment cycles" do
      other_cycle = create(:recruitment_cycle, year: "2025")
      other_provider = create(:provider, recruitment_cycle: other_cycle)
      create(:provider_school, provider: other_provider, gias_school:, site_code: "Z")
      create(:site, provider: other_provider, code: "C", urn: gias_school.urn)

      expect(report.orphan_provider_schools).to be_empty
      expect(report.unmapped_sites).to be_empty
    end
  end

  describe "#counts" do
    it "summarises each check" do
      create(:provider_school, provider:, gias_school:, site_code: "Z")

      expect(report.counts).to include(orphan_provider_schools: 1, unmapped_sites: 0)
    end
  end
end
