# frozen_string_literal: true

require "rails_helper"

describe DataHub::SchoolsBackfill::Executor do
  subject(:executor) { described_class.new }

  describe "#execute" do
    context "with a provider whose school-type site has a matching GIAS school" do
      let(:provider) { create(:provider) }
      let(:gias_school) { create(:gias_school, urn: "100001") }
      let!(:site) do
        create(:site, provider: provider, urn: gias_school.urn, code: "A")
      end

      it "inserts one provider_school row matching the source site" do
        executor.execute

        provider_school = Provider::School.find_by!(
          provider_id: provider.id,
          gias_school_id: gias_school.id,
        )
        expect(provider_school.site_code).to eq("A")
      end

      it "does not insert provider_school for a different gias_school" do
        other_gias_school = create(:gias_school, urn: "999999")
        executor.execute

        expect(
          Provider::School.where(
            provider_id: provider.id,
            gias_school_id: other_gias_school.id,
          ),
        ).to be_empty
      end
    end

    context "with a course_site linked to a school whose URN matches GIAS" do
      let(:provider) { create(:provider) }
      let(:gias_school) { create(:gias_school, urn: "200002") }
      let(:site) do
        create(:site, provider: provider, urn: gias_school.urn, code: "B")
      end
      let(:course) { create(:course, provider: provider) }
      let!(:site_status) do
        create(:site_status, course: course, site: site)
      end

      it "inserts one course_school row with the correct site_code" do
        executor.execute

        course_school = Course::School.find_by!(
          course_id: course.id,
          gias_school_id: gias_school.id,
        )
        expect(course_school.site_code).to eq("B")
      end

      it "copies unpublished course_site rows too (parity with source)" do
        expect(Course::School.where(course_id: course.id).count).to eq(0)
        executor.execute
        expect(Course::School.where(course_id: course.id).count).to eq(1)
      end
    end

    context "with a site whose URN is nil" do
      let(:provider) { create(:provider) }
      let!(:site) do
        create(:site, provider: provider, urn: nil, code: "-", location_name: "Main")
      end

      it "does not insert a provider_school row" do
        executor.execute
        expect(Provider::School.where(provider_id: provider.id)).to be_empty
      end

      it "records the site in skipped_sites with reason 'no_urn'" do
        summary = executor.execute
        skipped = summary.full_summary["skipped_sites"].find { |row| row["site_id"] == site.id }
        expect(skipped).to include("reason" => "no_urn")
      end
    end

    context "with a site whose URN does not match any GIAS school" do
      let(:provider) { create(:provider) }
      let!(:site) do
        create(:site, provider: provider, urn: "900009", code: "C")
      end

      it "does not insert a provider_school row" do
        executor.execute
        expect(Provider::School.where(provider_id: provider.id)).to be_empty
      end

      it "records the site in skipped_sites with reason 'urn_not_in_gias_school'" do
        summary = executor.execute
        skipped = summary.full_summary["skipped_sites"].find { |row| row["site_id"] == site.id }
        expect(skipped).to include("reason" => "urn_not_in_gias_school")
      end
    end

    context "with a discarded school-type site" do
      let(:provider) { create(:provider) }
      let(:gias_school) { create(:gias_school, urn: "300003") }
      let!(:site) do
        create(
          :site,
          provider: provider,
          urn: gias_school.urn,
          code: "D",
          discarded_at: 1.day.ago,
        )
      end

      it "does not insert a provider_school row" do
        executor.execute
        expect(Provider::School.where(provider_id: provider.id)).to be_empty
      end

      it "does not record the site in skipped_sites" do
        summary = executor.execute
        ids = summary.full_summary["skipped_sites"].map { |row| row["site_id"] }
        expect(ids).not_to include(site.id)
      end
    end

    context "with a study site" do
      let(:provider) { create(:provider) }
      let(:gias_school) { create(:gias_school, urn: "400004") }
      let!(:site) do
        create(:site, :study_site, provider: provider, urn: gias_school.urn, code: "E")
      end

      it "does not insert a provider_school row" do
        executor.execute
        expect(Provider::School.where(provider_id: provider.id)).to be_empty
      end

      it "does not record the site in skipped_sites" do
        summary = executor.execute
        ids = summary.full_summary["skipped_sites"].map { |row| row["site_id"] }
        expect(ids).not_to include(site.id)
      end
    end

    context "idempotency — executing twice" do
      let(:provider) { create(:provider) }
      let(:gias_school) { create(:gias_school, urn: "500005") }

      before do
        site = create(:site, provider: provider, urn: gias_school.urn, code: "F")
        course = create(:course, provider: provider)
        create(:site_status, course: course, site: site)
      end

      it "does not duplicate rows and reports zero inserts on the second run" do
        first = executor.execute
        expect(first.short_summary["provider_schools_inserted"]).to eq(1)
        expect(first.short_summary["course_schools_inserted"]).to eq(1)

        expect { described_class.new.execute }
          .to not_change { Provider::School.count }
          .and(not_change { Course::School.count })

        second = DataHub::SchoolsBackfillProcessSummary.order(:started_at).last
        expect(second.short_summary["provider_schools_inserted"]).to eq(0)
        expect(second.short_summary["course_schools_inserted"]).to eq(0)
      end
    end

    context "process summary lifecycle" do
      it "returns a finished summary with counts and skipped-row details" do
        provider = create(:provider)
        gias_school = create(:gias_school, urn: "600006")
        create(:site, provider: provider, urn: gias_school.urn, code: "G")

        summary = executor.execute

        expect(summary).to be_a(DataHub::SchoolsBackfillProcessSummary)
        expect(summary.status).to eq("finished")
        expect(summary.finished_at).to be_present
        expect(summary.short_summary["provider_schools_inserted"]).to eq(1)
        expect(summary.full_summary["skipped_sites"]).to eq([])
        expect(summary.full_summary["skipped_course_sites"]).to eq([])
      end

      it "marks the summary as failed and re-raises on error" do
        failing_executor = described_class.new
        allow(failing_executor).to receive(:insert_course_schools).and_raise(StandardError, "boom")

        expect { failing_executor.execute }.to raise_error(StandardError, "boom")

        summary = DataHub::SchoolsBackfillProcessSummary.order(:started_at).last
        expect(summary.status).to eq("failed")
        expect(summary.short_summary["error_message"]).to eq("boom")
      end

      it "rolls back provider_school inserts when course_school insert fails" do
        provider = create(:provider)
        gias_school = create(:gias_school, urn: "700007")
        create(:site, provider: provider, urn: gias_school.urn, code: "H")

        failing_executor = described_class.new
        allow(failing_executor).to receive(:insert_course_schools).and_raise(StandardError, "boom")

        expect { failing_executor.execute }.to raise_error(StandardError, "boom")
        expect(Provider::School.where(provider_id: provider.id)).to be_empty
      end
    end

    context "across multiple recruitment cycles" do
      it "backfills sites and course_sites from every cycle" do
        previous_cycle = create(:recruitment_cycle, :previous)
        current_cycle = find_or_create(:recruitment_cycle)

        previous_provider = create(:provider, recruitment_cycle: previous_cycle)
        current_provider = create(:provider, recruitment_cycle: current_cycle)
        previous_gias_school = create(:gias_school, urn: "810008")
        current_gias_school = create(:gias_school, urn: "820008")

        create(:site, provider: previous_provider, urn: previous_gias_school.urn, code: "P")
        create(:site, provider: current_provider, urn: current_gias_school.urn, code: "Q")

        executor.execute

        expect(
          Provider::School.where(provider_id: previous_provider.id, gias_school_id: previous_gias_school.id),
        ).to exist
        expect(
          Provider::School.where(provider_id: current_provider.id, gias_school_id: current_gias_school.id),
        ).to exist
      end
    end
  end
end
