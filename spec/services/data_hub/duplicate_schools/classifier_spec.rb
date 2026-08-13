# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::DuplicateSchools::Classifier do
  let(:provider) { create(:provider) }
  let(:year) { provider.recruitment_cycle.year }
  let(:classifier) { described_class.new(years: [year]) }

  # Site validates urn uniqueness per provider, so the real duplicates only
  # exist because something bypassed it (rollover copies with save!(validate:
  # false)). Specs reproduce them the same way.
  def duplicate_of(site, code:, location_name: site.location_name)
    build(:site, provider: site.provider, urn: site.urn, code:, location_name:, postcode: site.postcode)
      .tap { |duplicate| duplicate.save(validate: false) }
  end

  def school(urn:, code:, location_name: "Example School", **attrs)
    create(:site, provider:, urn:, code:, location_name:, **attrs)
  end

  def group_for(urn)
    classifier.call.find { |group| group.urn == urn }
  end

  def kind_of(urn)
    group_for(urn).kind
  end

  describe "#call" do
    it "groups kept school sites sharing a provider and urn" do
      site = school(urn: "100001", code: "A")
      twin = duplicate_of(site, code: "B")

      group = group_for("100001")

      expect(group.sites.map(&:id)).to contain_exactly(site.id, twin.id)
      expect(group.provider).to eq(provider)
      expect(group.year).to eq(year)
    end

    it "ignores a urn held by a single site" do
      school(urn: "100002", code: "A")

      expect(group_for("100002")).to be_nil
    end

    it "ignores discarded duplicates" do
      site = school(urn: "100003", code: "A")
      duplicate_of(site, code: "B").discard!

      expect(group_for("100003")).to be_nil
    end

    it "ignores study sites" do
      site = school(urn: "100004", code: "A")
      duplicate_of(site, code: "B").update_column(:site_type, Site.site_types[:study_site])

      expect(group_for("100004")).to be_nil
    end

    it "ignores sites without a urn" do
      create(:site, provider:, code: "-", urn: nil, location_name: "Main Site")
      school(urn: "100007", code: "Z", location_name: "Other Site").update_column(:urn, nil)

      expect(classifier.call).to be_empty
    end

    it "ignores other recruitment cycles" do
      other = create(:provider, recruitment_cycle: create(:recruitment_cycle, :previous))
      site = create(:site, provider: other, urn: "100005", code: "A", location_name: "Elsewhere")
      duplicate_of(site, code: "B")

      expect(group_for("100005")).to be_nil
    end

    it "includes the main site, which the original CSV query excluded" do
      main = school(urn: "100006", code: "-", location_name: "Main Site")
      duplicate_of(main, code: "K", location_name: "Example School")

      expect(group_for("100006").codes).to include("-")
    end

    it "carries the GIAS school and the provider_school rows the sites became" do
      gias_school = create(:gias_school, :open, urn: "100008", name: "Lampton Academy")
      site = school(urn: "100008", code: "E", location_name: "Lampton Academy")
      duplicate_of(site, code: "F")
      provider_school = create(:provider_school, provider:, gias_school:, site_code: "E")

      group = group_for("100008")

      expect(group.gias_school).to eq(gias_school)
      expect(group.provider_schools).to contain_exactly(provider_school)
    end
  end

  describe "classification" do
    it "calls repeated rows under one code a clone" do
      site = school(urn: "200001", code: "A", location_name: "Hopwood Hall College")
      duplicate_of(site, code: "A")

      expect(kind_of("200001")).to be_a(DataHub::DuplicateSchools::Kind::Clone)
      expect(kind_of("200001").label).to eq("clone")
    end

    it "calls one school under two codes a split code twin" do
      site = school(urn: "200002", code: "DK", location_name: "Hilltop Infant School")
      duplicate_of(site, code: "DN")

      expect(kind_of("200002")).to be_a(DataHub::DuplicateSchools::Kind::SplitCodeTwin)
    end

    it "calls a group holding the main site a main site collision" do
      main = school(urn: "200003", code: "-", location_name: "Main Site")
      duplicate_of(main, code: "E", location_name: "Lampton Academy")

      expect(kind_of("200003")).to be_a(DataHub::DuplicateSchools::Kind::MainSiteCollision)
    end

    it "prefers the main site collision over the clone shape" do
      main = school(urn: "200004", code: "-", location_name: "Main Site")
      duplicate_of(main, code: "-")

      expect(kind_of("200004")).to be_a(DataHub::DuplicateSchools::Kind::MainSiteCollision)
    end

    it "calls two codes under two names a divergent name twin" do
      site = school(urn: "200005", code: "DM", location_name: "George Abbot School")
      duplicate_of(site, code: "EE", location_name: "Main site Secondary- one of our partner schools")

      expect(kind_of("200005")).to be_a(DataHub::DuplicateSchools::Kind::DivergentNameTwin)
    end
  end

  describe "flags" do
    it "flags a main site the existing deduplicator would discard" do
      main = school(urn: "300001", code: "-", location_name: "Main Site")
      twin = duplicate_of(main, code: "E", location_name: "Lampton Academy")
      create(:site_status, site: twin, course: create(:course, provider:))

      expect(kind_of("300001").flags).to include(main_site_at_risk: true)
    end

    it "does not flag a main site that already holds the most courses" do
      main = school(urn: "300002", code: "-", location_name: "Main Site")
      duplicate_of(main, code: "E", location_name: "Lampton Academy")
      create(:site_status, site: main, course: create(:course, provider:))

      expect(kind_of("300002").flags).to include(main_site_at_risk: false)
    end

    it "flags courses held on both sides of a collision" do
      main = school(urn: "300003", code: "-", location_name: "Main Site")
      twin = duplicate_of(main, code: "E", location_name: "Lampton Academy")
      create(:site_status, site: main, course: create(:course, provider:))
      create(:site_status, site: twin, course: create(:course, provider:))

      expect(kind_of("300003").flags).to include(courses_on_both_sides: true)
    end

    it "flags a group whose GIAS record has closed" do
      create(:gias_school, :closed, urn: "300004")
      site = school(urn: "300004", code: "P", location_name: "Shrewsbury College")
      duplicate_of(site, code: "P")

      expect(kind_of("300004").flags).to include(gias_closed: true)
    end

    it "flags a divergent name the provider wrote themselves" do
      create(:gias_school, :open, urn: "300005", name: "George Abbot School")
      site = school(urn: "300005", code: "DM", location_name: "George Abbot School")
      duplicate_of(site, code: "EE", location_name: "Main site Secondary- one of our partner schools")

      expect(kind_of("300005").flags).to include(provider_authored_name: true)
    end

    it "does not flag a plain main site label as provider written" do
      create(:gias_school, :open, urn: "300006", name: "Oakthorpe Primary School")
      site = school(urn: "300006", code: "M", location_name: "Main Site")
      duplicate_of(site, code: "O", location_name: "Oakthorpe Primary School")

      expect(kind_of("300006").flags).to include(provider_authored_name: false)
    end
  end
end
