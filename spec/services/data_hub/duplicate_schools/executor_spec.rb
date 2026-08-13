# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::DuplicateSchools::Executor do
  subject(:executor) { described_class.new(years: [year], io: StringIO.new) }

  let(:provider) { create(:provider) }
  let(:year) { provider.recruitment_cycle.year }

  before do
    create(:gias_school, :open, urn: "144834", name: "Hilltop Infant School")
    site = create(:site, provider:, urn: "144834", code: "DK", location_name: "Hilltop Infant School")
    build(:site, provider:, urn: "144834", code: "DN", location_name: "Hilltop Infant School", postcode: site.postcode)
      .save(validate: false)
  end

  it "records the classification in a process summary" do
    expect { executor.execute }.to change(DataHub::DuplicateSchoolsProcessSummary, :count).by(1)

    process_summary = DataHub::DuplicateSchoolsProcessSummary.order(:created_at).last

    expect(process_summary.status).to eq("finished")
    expect(process_summary.years).to eq([year])
    expect(process_summary.groups_processed).to eq(1)
    expect(process_summary.surplus_sites).to eq(1)
    expect(process_summary.kinds).to contain_exactly(
      hash_including("kind" => "split_code_twin", "groups" => 1),
    )
  end

  it "records the evidence behind the counts" do
    executor.execute

    group = DataHub::DuplicateSchoolsProcessSummary.last.duplicate_groups.sole

    expect(group["urn"]).to eq("144834")
    expect(group["kind"]).to eq("split_code_twin")
    expect(group["sites"].map { |site| site["code"] }).to contain_exactly("DK", "DN")
  end

  it "returns the process summary" do
    expect(executor.execute).to be_a(DataHub::DuplicateSchoolsProcessSummary)
  end

  it "changes nothing else" do
    expect { executor.execute }
      .to not_change { Site.kept.pluck(:id, :code, :location_name, :urn, :discarded_at) }
      .and(not_change { Provider::School.pluck(:id, :site_code, :gias_school_id) })
  end

  it "marks the process summary as failed when an error occurs" do
    allow(DataHub::DuplicateSchools::Classifier).to receive(:new).and_raise(StandardError.new("boom"))

    expect { executor.execute }.to raise_error(StandardError, "boom")

    expect(DataHub::DuplicateSchoolsProcessSummary.last.status).to eq("failed")
    expect(DataHub::DuplicateSchoolsProcessSummary.last.short_summary["error_message"]).to eq("boom")
  end
end
