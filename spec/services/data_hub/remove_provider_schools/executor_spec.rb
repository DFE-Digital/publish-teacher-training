require "rails_helper"

RSpec.describe DataHub::RemoveProviderSchools::Executor do
  subject(:executor) do
    described_class.new(provider_code: provider.provider_code, keep_urns:, year:, discarder_class:)
  end

  let(:recruitment_cycle) { RecruitmentCycle.current }
  let(:year) { recruitment_cycle.year }
  let!(:provider) { create(:provider, recruitment_cycle:) }
  let(:keep_urns) { %w[11111 22222] }

  let!(:keep_site) { create(:site, provider:, urn: "11111", location_name: "Keep School") }
  let!(:remove_site)          { create(:site, provider:, urn: "99999", location_name: "Remove School") }
  let!(:remove_with_course)   { create(:site, provider:, urn: "77777", location_name: "Has Course School") }

  before do
    # Attach remove_with_course to a kept course so it must be skipped.
    course = create(:course, provider:)
    create(:site_status, status: "running", site: remove_with_course, course:)
  end

  context "with real discarder" do
    let(:discarder_class) { DataHub::RemoveProviderSchools::SiteDiscarder }

    it "discards only schools that are not kept and have no course" do
      expect { executor.execute }.to change { Site.discarded.count }.by(1)

      expect(remove_site.reload).to be_discarded
      expect(keep_site.reload).not_to be_discarded
      expect(remove_with_course.reload).not_to be_discarded
    end

    it "records a summary with removed, skipped and keep-list reconciliation" do
      executor.execute

      summary = DataHub::RemoveProviderSchoolsProcessSummary.last
      expect(summary.removed_count).to eq(1)
      expect(summary.skipped_with_courses_count).to eq(1)
      expect(summary.kept_present_count).to eq(1)
      expect(summary.kept_missing_count).to eq(1)
      expect(summary.kept_present).to eq(%w[11111])
      expect(summary.kept_missing).to eq(%w[22222])
    end
  end

  context "with dry run discarder" do
    let(:discarder_class) { DataHub::RemoveProviderSchools::DryRunSiteDiscarder }

    it "does NOT discard any sites" do
      expect { executor.execute }.not_to(change { Site.discarded.count })
    end

    it "still records what would be removed" do
      executor.execute

      summary = DataHub::RemoveProviderSchoolsProcessSummary.last
      expect(summary.removed_count).to eq(1)
      expect(summary.skipped_with_courses_count).to eq(1)
    end
  end
end
