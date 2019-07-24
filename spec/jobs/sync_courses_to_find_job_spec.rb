require 'rails_helper'

describe SyncCoursesToFindJob, type: :job do
  let(:course) { create :course }

  before do
    allow(SearchAndCompareAPIService::Request).to receive(:sync)
  end

  it 'queues the expected job' do
    described_class.perform_later(course)

    expect(SyncCoursesToFindJob)
      .to have_been_enqueued.with(course).on_queue('find_sync')
  end

  it 'syncs using the SearchAndCompareAPIService' do
    described_class.perform_now(course)

    expect(SearchAndCompareAPIService::Request)
      .to have_received(:sync).with([course])
  end
end
