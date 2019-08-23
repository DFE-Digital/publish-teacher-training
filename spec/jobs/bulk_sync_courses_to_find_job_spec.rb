require 'rails_helper'

describe BulkSyncCoursesToFindJob, type: :job do
  let(:site) { build(:site) }
  let(:provider) { build(:provider, sites: [site]) }
  let(:site_status) do
    build(:site_status, :findable, site: provider.sites.first)
  end
  let(:course_enrichment) { build(:course_enrichment, :published) }
  let(:subjects) { [create(:further_education_subject)] }
  let(:course) do
    create(:course, provider: provider, site_statuses: [site_status],
      enrichments: [course_enrichment], subjects: subjects)
  end
  let!(:syncable_courses) { [course] }
  before do
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
