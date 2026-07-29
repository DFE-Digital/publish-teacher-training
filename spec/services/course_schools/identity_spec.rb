# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseSchools::Identity do
  let(:remodel_cycle_year) { 2026 }
  let(:gias_school) { create(:gias_school, urn: "123456", name: "Bell School") }
  let(:unknown_school_uuid) { Faker::Internet.uuid }

  before do
    allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
  end

  # provider_school.uuid is a copy of site.uuid while legacy sites are still
  # written — see DataHub::SchoolsBackfill::Executor and the dual-write in
  # Publish::Providers::Schools::ChecksController.
  def paired_school(provider:, gias_school:, site_code: "A")
    uuid = Faker::Internet.uuid
    site = create(:site, provider:, urn: gias_school.urn, code: site_code, uuid:)
    provider_school = create(:provider_school, provider:, gias_school:, site_code:, uuid:)
    [site, provider_school]
  end

  shared_examples "a Provider::School read model" do
    let(:course) { create(:course, provider:) }
    let!(:pair) { paired_school(provider:, gias_school:) }
    let(:site) { pair.first }
    let(:provider_school) { pair.last }

    describe "#available_schools" do
      it "returns Provider::School records, never legacy sites" do
        identity = described_class.new(provider:, course:)

        expect(identity.available_schools).to contain_exactly(provider_school)
      end

      it "orders by the GIAS school name" do
        _, zebra = paired_school(provider:, gias_school: create(:gias_school, name: "Zebra School"), site_code: "B")
        _, apple = paired_school(provider:, gias_school: create(:gias_school, name: "Apple School"), site_code: "C")

        identity = described_class.new(provider:, course:)

        expect(identity.available_schools.to_a).to eq([apple, provider_school, zebra])
      end

      it "stays unloaded until it is needed" do
        identity = described_class.new(provider:, course:)
        available_schools = identity.available_schools

        expect(available_schools).to be_a(ActiveRecord::Relation)
        expect(available_schools).not_to be_loaded
        expect(identity.available_schools_count).to eq(1)
        expect(available_schools).not_to be_loaded
      end

      # The gap DataHub::SchoolsRemodelPreflight::Report#unmapped_sites counts.
      it "omits a legacy site that has no Provider::School" do
        create(:site, provider:, code: "Z", urn: create(:gias_school).urn)

        identity = described_class.new(provider:, course:)

        expect(identity.available_schools).to contain_exactly(provider_school)
      end
    end

    describe "#school_records_for" do
      it "resolves provider school uuids to Provider::School records" do
        identity = described_class.new(provider:, course:)

        expect(identity.school_records_for(school_uuids: [provider_school.uuid]).records)
          .to eq([provider_school])
      end

      it "preserves the submitted order" do
        _, other = paired_school(provider:, gias_school: create(:gias_school), site_code: "B")
        identity = described_class.new(provider:, course:)

        result = identity.school_records_for(school_uuids: [other.uuid, provider_school.uuid])

        expect(result.records).to eq([other, provider_school])
      end

      it "deduplicates repeated uuids" do
        identity = described_class.new(provider:, course:)

        expect(identity.school_records_for(school_uuids: [provider_school.uuid, provider_school.uuid]).records)
          .to eq([provider_school])
      end

      # A colleague removing a school between render and submit must not 500.
      it "reports an unknown uuid as unresolved rather than raising" do
        identity = described_class.new(provider:, course:)

        result = identity.school_records_for(school_uuids: [unknown_school_uuid])

        expect(result.records).to be_empty
        expect(result.unresolved_uuids).to eq([unknown_school_uuid])
        expect(result).not_to be_all_resolved
      end

      it "reports a school belonging to another provider as unresolved" do
        other_provider_school = create(:provider_school, uuid: unknown_school_uuid)
        identity = described_class.new(provider:, course:)

        result = identity.school_records_for(school_uuids: [other_provider_school.uuid])

        expect(result.unresolved_uuids).to eq([unknown_school_uuid])
      end

      it "returns the resolvable records alongside the unresolved uuids" do
        identity = described_class.new(provider:, course:)

        result = identity.school_records_for(school_uuids: [provider_school.uuid, unknown_school_uuid])

        expect(result.records).to eq([provider_school])
        expect(result.unresolved_uuids).to eq([unknown_school_uuid])
      end

      # Stale wizard state and tampered forms both land here.
      it "treats a value that is not a uuid as unresolved" do
        identity = described_class.new(provider:, course:)

        result = identity.school_records_for(school_uuids: [site.id.to_s])

        expect(result.records).to be_empty
        expect(result.unresolved_uuids).to eq([site.id.to_s])
      end

      it "ignores blank values" do
        identity = described_class.new(provider:, course:)

        result = identity.school_records_for(school_uuids: ["", nil, provider_school.uuid])

        expect(result.records).to eq([provider_school])
        expect(result).to be_all_resolved
      end
    end
  end

  context "when the provider is in the schools remodel cycle" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year) }
    let(:provider) { create(:provider, recruitment_cycle:) }

    it_behaves_like "a Provider::School read model"

    it "still writes legacy sites" do
      expect(described_class.new(provider:)).to be_legacy_site_writes
    end

    describe "#current_school_uuids" do
      let(:course) { create(:course, provider:) }
      let!(:pair) { paired_school(provider:, gias_school:) }
      let(:site) { pair.first }
      let(:provider_school) { pair.last }

      it "reads attachments from the new model" do
        create(:course_school, course:, provider_school:, gias_school:)

        expect(described_class.new(provider:, course:).current_school_uuids)
          .to contain_exactly(provider_school.uuid)
      end

      # The 700-course gap in school-mapping-gaps-by-provider.md: a live
      # site_status with no course_school row. Without this the picker renders
      # the school unticked and the next save silently detaches it.
      it "rescues an attachment that exists only as a site_status" do
        create(:site_status, :running, course:, site:)

        expect(described_class.new(provider:, course:).current_school_uuids)
          .to contain_exactly(provider_school.uuid)
      end

      it "does not double-count a school attached under both models" do
        create(:course_school, course:, provider_school:, gias_school:)
        create(:site_status, :running, course:, site:)

        expect(described_class.new(provider:, course:).current_school_uuids)
          .to contain_exactly(provider_school.uuid)
      end

      # Nothing can represent this in the picker, so it must not appear as
      # attached — otherwise the write path would try to detach it.
      it "omits a site_status whose site has no Provider::School" do
        orphan_site = create(:site, provider:, code: "Z", urn: create(:gias_school).urn)
        create(:site_status, :running, course:, site: orphan_site)

        expect(described_class.new(provider:, course:).current_school_uuids).to be_empty
      end

      it "ignores suspended attachments" do
        create(:site_status, :suspended, course:, site:)

        expect(described_class.new(provider:, course:).current_school_uuids).to be_empty
      end
    end
  end

  context "when the provider is after the schools remodel cycle" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year + 1) }
    let(:provider) { create(:provider, recruitment_cycle:) }

    it_behaves_like "a Provider::School read model"

    it "no longer writes legacy sites" do
      expect(described_class.new(provider:)).not_to be_legacy_site_writes
    end

    describe "#current_school_uuids" do
      let(:course) { create(:course, provider:) }

      it "reads attachments from the new model only" do
        _, provider_school = paired_school(provider:, gias_school:)
        create(:course_school, course:, provider_school:, gias_school:)

        expect(described_class.new(provider:, course:).current_school_uuids)
          .to contain_exactly(provider_school.uuid)
      end

      # After rollover Rollover::Schools::ProviderCopier mints fresh uuids, so
      # site.uuid and provider_school.uuid diverge and the legacy rescue would
      # be actively wrong.
      it "ignores legacy site_statuses entirely" do
        site = create(:site, provider:, urn: gias_school.urn, code: "A")
        create(:provider_school, provider:, gias_school:, site_code: "A")
        create(:site_status, :running, course:, site:)

        expect(described_class.new(provider:, course:).current_school_uuids).to be_empty
      end
    end
  end

  context "when initialized without a course" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let!(:pair) { paired_school(provider:, gias_school:) }

    it "supports provider-only school lists" do
      expect(described_class.new(provider:).available_schools).to contain_exactly(pair.last)
    end

    it "raises a descriptive error for course-specific school UUIDs" do
      expect { described_class.new(provider:).current_school_uuids }
        .to raise_error(ArgumentError, /requires a course for current_school_uuids/)
    end
  end
end
