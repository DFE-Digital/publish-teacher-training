RSpec.describe Course, type: :model do
  describe '#publish_sites' do
    let(:published_new_site)            { create(:site_status, :published, :new) }
    let(:published_running_site)        { create(:site_status, :published, :running) }
    let(:published_discontinued_site)   { create(:site_status, :published, :discontinued) }
    let(:published_suspended_site)      { create(:site_status, :published, :suspended) }
    let(:unpublished_new_site)          { create(:site_status, :unpublished, :new) }
    let(:unpublished_running_site)      { create(:site_status, :unpublished, :running) }
    let(:unpublished_discontinued_site) { create(:site_status, :unpublished, :discontinued) }
    let(:unpublished_suspended_site)    { create(:site_status, :unpublished, :suspended) }

    before do
      course.publish_sites
    end

    context 'on an old course with a site' do
      let(:course) { create(:course, site_statuses: [published_new_site], age: 5.days.ago) }
      it 'updates course.changed_at' do
        expect(course.changed_at).to be_within(1.second).of Time.now.utc
      end
    end

    context 'on a course with many sites' do
      let(:course) {
        create(:course, site_statuses: [
                 published_new_site,
                 published_running_site,
                 published_discontinued_site,
                 published_suspended_site,
                 unpublished_new_site,
                 unpublished_running_site,
                 unpublished_discontinued_site,
                 unpublished_suspended_site
               ])
      }

      it 'sets all the sites to the right published/status states' do
        expect(published_new_site.reload).to be_published_on_ucas
        expect(published_new_site).to be_status_running
        expect(published_running_site.reload).to be_published_on_ucas
        expect(published_running_site).to be_status_running
        expect(published_discontinued_site.reload).to be_published_on_ucas
        expect(published_discontinued_site).to be_status_discontinued
        expect(published_suspended_site.reload).to be_published_on_ucas
        expect(published_suspended_site).to be_status_suspended
        expect(unpublished_new_site.reload).to be_published_on_ucas
        expect(unpublished_new_site).to be_status_running
        expect(unpublished_running_site.reload).to be_published_on_ucas
        expect(unpublished_running_site).to be_status_running
        expect(unpublished_discontinued_site.reload).to be_unpublished_on_ucas
        expect(unpublished_discontinued_site).to be_status_discontinued
        expect(unpublished_suspended_site.reload).to be_unpublished_on_ucas
        expect(unpublished_suspended_site).to be_status_suspended
      end
    end
  end
end
