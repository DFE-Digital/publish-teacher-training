require "rails_helper"

describe SyncCoursesToFindJob, type: :job do
  let(:course) { create :course }

  before do
    allow_any_instance_of(SearchAndCompareAPIService::Request)
      .to receive(:sync).and_return(true)
  end

  it "queues the expected job" do
    described_class.perform_later(course)

    expect(SyncCoursesToFindJob)
      .to have_been_enqueued.with.on_queue("find_sync")
  end

  it "syncs using the SearchAndCompareAPIService" do
    expect_any_instance_of(SearchAndCompareAPIService::Request)
      .to receive(:sync).with([course])

    described_class.perform_now(course)
  end
end
