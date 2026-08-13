# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::DuplicateSchools::SummaryBuilder do
  subject(:builder) { described_class.new(groups:, years: [year]) }

  let(:provider) { create(:provider) }
  let(:year) { provider.recruitment_cycle.year }
  let(:groups) { DataHub::DuplicateSchools::Classifier.new(years: [year]).call }

  def duplicate_of(site, code:, location_name: site.location_name)
    build(:site, provider: site.provider, urn: site.urn, code:, location_name:, postcode: site.postcode)
      .tap { |duplicate| duplicate.save(validate: false) }
  end

  before do
    gias_school = create(:gias_school, :open, urn: "144834", name: "Hilltop Infant School")
    twin = create(:site, provider:, urn: "144834", code: "DK", location_name: "Hilltop Infant School")
    duplicate_of(twin, code: "DN")
    create(:site_status, site: twin, course: create(:course, provider:))
    create(:provider_school, provider:, gias_school:, site_code: "DK")
    create(:provider_school, provider:, gias_school:, site_code: "DN")

    create(:gias_school, :open, urn: "137979", name: "Chepping View Primary Academy")
    main = create(:site, provider:, urn: "137979", code: "-", location_name: "Main Site")
    placement = duplicate_of(main, code: "C", location_name: "Chepping View Primary Academy")
    # Courses on the placement row and none on the main site is what makes the
    # existing deduplicator discard the main site.
    create(:site_status, site: placement, course: create(:course, provider:))
  end

  describe "#short_summary" do
    it "counts the groups, the surplus rows and the years covered" do
      expect(builder.short_summary).to include(
        years: [year],
        groups_processed: 2,
        surplus_sites: 2,
        surplus_provider_schools: 1,
      )
    end

    it "tallies the groups by kind" do
      expect(builder.short_summary[:kinds]).to contain_exactly(
        { kind: "split_code_twin", groups: 1, surplus_sites: 1, surplus_provider_schools: 1 },
        { kind: "main_site_collision", groups: 1, surplus_sites: 1, surplus_provider_schools: 0 },
      )
    end

    it "tallies the raised flags, so a merge policy can be sized" do
      expect(builder.short_summary[:flags]).to include({ flag: "main_site_at_risk", groups: 1 })
    end
  end

  describe "#full_summary" do
    it "records each group with its kind and flags" do
      group = builder.full_summary[:duplicate_groups].find { |entry| entry[:urn] == "144834" }

      expect(group).to include(
        year: year,
        provider_code: provider.provider_code,
        urn: "144834",
        kind: "split_code_twin",
        gias_name: "Hilltop Infant School",
        gias_status: "open",
      )
    end

    it "records every site in the group with its course counts" do
      group = builder.full_summary[:duplicate_groups].find { |entry| entry[:urn] == "144834" }

      expect(group[:sites].map { |site| site.values_at(:code, :courses, :unique_courses) })
        .to contain_exactly(["DK", 1, 1], ["DN", 0, 0])
    end

    it "records the provider_school rows the sites became" do
      group = builder.full_summary[:duplicate_groups].find { |entry| entry[:urn] == "144834" }

      expect(group[:provider_schools].map { |row| row[:site_code] }).to contain_exactly("DK", "DN")
    end
  end
end
