require "rails_helper"

describe BulkSyncCoursesToFindJob, type: :job do
  let(:course) do
    create(:course)
  end
  let(:syncable_courses) { [course] }

  before do
    syncable_courses

    allow(RecruitmentCycle)
      .to receive(:syncable_courses).and_return(syncable_courses)

    allow_any_instance_of(SearchAndCompareAPIService::Request)
      .to receive(:bulk_sync).and_return(true)
  end

  it "queues the expected job" do
    described_class.perform_later

    expect(BulkSyncCoursesToFindJob)
      .to have_been_enqueued.on_queue("find_sync")
  end

  it "syncs using the SearchAndCompareAPIService" do
    expect_any_instance_of(SearchAndCompareAPIService::Request)
      .to receive(:bulk_sync).with(syncable_courses)

    described_class.perform_now
  end

  context "search and compare raises a 403 error" do
    let(:sacapi_response) { spy(status: 403) }
    let(:sacapi_service) { spy(response: sacapi_response) }

    before do
      allow(sacapi_service).to receive(:bulk_sync).and_return(false)
      allow(SearchAndCompareAPIService::Request).to receive(:new)
                                                      .and_return(sacapi_service)
    end

    it "raises an error if it gets an error" do
      expect {
        described_class.perform_now
      }.to raise_error(BulkSyncCoursesToFindJob::SearchAndCompareRequestError)
    end
  end

  context "search and compare raises a 502 error" do
    let(:sacapi_response) { spy(status: 502) }
    let(:sacapi_service) { spy(response: sacapi_response) }

    before do
      allow(sacapi_service).to receive(:bulk_sync).and_return(false)
      allow(SearchAndCompareAPIService::Request).to receive(:new)
                                                      .and_return(sacapi_service)
    end

    it "raises an error if it gets an error" do
      expect {
        described_class.perform_now
      }.not_to raise_error
    end
  end
end
