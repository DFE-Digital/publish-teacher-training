# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Sites::Deduplication::Deduplicator do
  let(:provider) { create(:provider) }

  def deduplicate_outcome(sites:, dry_run: false)
    described_class.new(
      site_scope: Site.where(id: sites.map(&:id)),
      dry_run:,
    ).call
  end

  def summary_for(outcome)
    DataHub::Sites::Deduplication::SummaryBuilder.new(outcome).short_summary
  end

  describe "#call" do
    context "when duplicate school sites exist" do
      let(:primary) do
        create(:site, provider:, location_name: "Example School", postcode: "SW1A 1AA", urn: "12345")
      end

      let(:duplicate) do
        create(:site, provider:, location_name: "Example School", postcode: "SW1A 1AA", urn: "12345")
      end

      let!(:primary_status) do
        create(:site_status, site: primary, course: create(:course, provider:), status: "running", publish: "Y", vac_status: "F")
      end

      let!(:duplicate_status) do
        create(:site_status, site: duplicate, course: create(:course, provider:), status: "new_status", publish: "N", vac_status: "")
      end

      let(:outcome) { deduplicate_outcome(sites: [primary, duplicate]) }
      let(:summary) { summary_for(outcome) }

      it "reassigns site statuses to the primary site and discards duplicates" do
        outcome

        expect(duplicate_status.reload.site).to eq(primary)
        expect(primary_status.reload.site).to eq(primary)
        expect(duplicate.reload).to be_discarded

        expect(summary[:duplicate_groups_processed]).to eq(1)
        expect(summary[:duplicate_sites_discarded]).to eq(1)
        expect(summary[:site_statuses_reassigned]).to eq(1)
      end
    end

    context "when duplicate site statuses exist for the same course" do
      let(:primary) do
        create(:site, provider:, location_name: "Shared School", postcode: "BN1 1AA", urn: "77777")
      end

      let(:duplicate) do
        create(:site, provider:, location_name: "Shared School", postcode: "BN1 1AA", urn: "77777")
      end

      let(:course) { create(:course, provider:, study_mode: :full_time_or_part_time) }

      let!(:existing_status) do
        create(:site_status, site: primary, course:, status: "new_status", publish: "N", vac_status: "")
      end

      let!(:redundant_status) do
        create(:site_status, site: duplicate, course:, status: "running", publish: "Y", vac_status: "B")
      end

      let(:outcome) { deduplicate_outcome(sites: [primary, duplicate]) }
      let(:summary) { summary_for(outcome) }

      it "prefers the better status configuration and removes the duplicate" do
        outcome

        expect { redundant_status.reload }.to raise_error(ActiveRecord::RecordNotFound)

        expect(existing_status.reload.status).to eq("running")
        expect(existing_status.publish).to eq("published")
        expect(existing_status.vac_status).to eq("no_vacancies")

        expect(summary[:site_statuses_merged]).to eq(1)
        expect(summary[:site_statuses_removed]).to eq(1)
      end
    end

    context "when running in dry-run mode" do
      let(:primary) do
        create(:site, provider:, location_name: "Dry School", postcode: "LS1 1UR", urn: "88888")
      end

      let(:duplicate) do
        create(:site, provider:, location_name: "Dry School", postcode: "LS1 1UR", urn: "88888")
      end

      let!(:primary_status) do
        create(:site_status, site: primary, course: create(:course, provider:), status: "running", publish: "N", vac_status: "F")
      end

      let!(:duplicate_status) do
        create(:site_status, site: duplicate, course: create(:course, provider:), status: "running", publish: "Y", vac_status: "F")
      end

      let(:outcome) { deduplicate_outcome(sites: [primary, duplicate], dry_run: true) }
      let(:summary) { summary_for(outcome) }

      it "reports planned changes and leaves data untouched" do
        outcome

        expect(duplicate.reload).not_to be_discarded
        expect(primary_status.reload.site).to eq(primary)
        expect(duplicate_status.reload.site).to eq(duplicate)

        expect(summary[:dry_run]).to eq(true)
        expect(summary[:site_statuses_reassigned]).to eq(1)
        expect(summary[:duplicate_sites_discarded]).to eq(1)
      end
    end

    context "when school sites are missing URNs" do
      let(:primary) do
        create(:site, provider:, urn: nil, location_name: "No URN A", postcode: "SW1A 1AA")
      end

      let(:duplicate) do
        create(:site, provider:, urn: nil, location_name: "No URN B", postcode: "SW1A 1AA")
      end

      let!(:duplicate_status) do
        create(:site_status, site: duplicate, course: create(:course, provider:), status: "running", publish: "Y", vac_status: "F")
      end

      let(:outcome) { deduplicate_outcome(sites: [primary, duplicate]) }
      let(:summary) { summary_for(outcome) }

      it "skips deduplication" do
        outcome

        expect(outcome.groups).to be_empty

        expect(summary[:duplicate_groups_processed]).to eq(0)
        expect(summary[:duplicate_sites_discarded]).to eq(0)

        expect(primary.reload.discarded?).to be(false)
        expect(duplicate.reload.discarded?).to be(false)
        expect(duplicate_status.reload.site).to eq(duplicate)
      end
    end

    context "when duplicate sites are study sites" do
      let(:primary) do
        build(:site, :study_site, provider:, location_name: "Placement", postcode: "EC1A 1BB", urn: "99001").tap do |site|
          site.save(validate: false) # bypass name uniqueness validation
        end
      end

      let(:duplicate) do
        build(:site, :study_site, provider:, location_name: "Placement", postcode: "EC1A 1BB", urn: "99001").tap do |site|
          site.save(validate: false) # bypass name uniqueness validation
        end
      end

      let!(:placement) do
        create(:study_site_placement, course: create(:course, provider:), site: duplicate)
      end

      let(:outcome) { deduplicate_outcome(sites: [primary, duplicate]) }

      it "ignores the duplicates" do
        outcome

        expect(outcome.groups).to be_empty
        expect(primary.reload.discarded?).to be(false)
        expect(duplicate.reload.discarded?).to be(false)
        expect(placement.reload.site).to eq(duplicate)
      end
    end
  end
end
