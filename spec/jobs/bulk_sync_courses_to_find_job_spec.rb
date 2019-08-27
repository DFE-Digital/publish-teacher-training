require 'rails_helper'

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

  xit 'queues the expected job' do
    described_class.perform_later

    # this is filmsy see SyncCoursesToFindJob verion and replace course with nil
    expect(BulkSyncCoursesToFindJob)
      .to have_been_enqueued.with(syncable_courses).on_queue(:find_sync)
  end

  it 'syncs using the SearchAndCompareAPIService' do
    expect_any_instance_of(SearchAndCompareAPIService::Request)
      .to receive(:bulk_sync).with(syncable_courses)

    described_class.perform_now
  end
end
