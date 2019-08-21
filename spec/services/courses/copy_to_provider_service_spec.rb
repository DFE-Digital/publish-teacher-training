require 'rails_helper'

RSpec.describe Courses::CopyToProviderService do
  let(:accrediting_provider) { create :provider, :accredited_body }
  let(:provider) { create :provider, courses: [course] }
  let(:maths) { create :subject, :mathematics }
  let(:course) {
    build :course,
          accrediting_provider: accrediting_provider,
          subjects: [maths]
  }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:new_recruitment_cycle) { create :recruitment_cycle, :next }
  let(:new_provider) {
    create :provider,
           provider_code: provider.provider_code,
           recruitment_cycle: new_recruitment_cycle
  }
  let(:new_course) {
    new_provider.reload.courses.find_by(course_code: course.course_code)
  }

  let(:service) { described_class.new(course: course) }

  it 'makes a copy of the course in the new provider' do
    service.execute(new_provider)

    expect(new_course).not_to be_nil
    expect(new_course.accrediting_provider_code)
      .to eq course.accrediting_provider_code
    expect(new_course.subjects).to eq course.subjects
    expect(new_course.content_status).to eq :rolled_over
    expect(new_course.ucas_status).to eq :new
    expect(new_course.open_for_applications?).to be_falsey
  end

  it 'leaves the existing course alone' do
    service.execute(new_provider)

    expect(provider.reload.courses).to eq [course]
  end

  context 'course has a published but no draft enrichment' do
    let!(:published_enrichment) do
      create :course_enrichment, :published, course: course
    end

    before { service.execute(new_provider) }

    subject { new_course.enrichments }

    its(:length) { should eq 1 }

    describe 'the new course' do
      subject { new_course }

      its(:content_status) { should eq :rolled_over }
    end

    describe 'the copied enrichment' do
      subject { new_course.enrichments.first }

      its(:about_course) { should eq published_enrichment.about_course }
      its(:last_published_timestamp_utc) { should be_nil }
      it { should be_rolled_over }
    end
  end

  context 'course has a published and a draft enrichment' do
    let!(:published_enrichment) do
      create :course_enrichment, :published, course: course
    end
    let!(:draft_enrichment) do
      create :course_enrichment, course: course
    end

    before { service.execute(new_provider) }

    subject { new_course.enrichments }

    its(:length) { should eq 1 }

    describe 'the new course' do
      subject { new_course }

      its(:content_status) { should eq :rolled_over }
    end

    describe 'the copied enrichment' do
      subject { new_course.enrichments.first }

      its(:about_course) { should eq draft_enrichment.about_course }
      it { should be_rolled_over }
    end
  end

  context 'the course already exists in the new provider' do
    let!(:new_course) {
      create :course,
             course_code: course.course_code,
             provider: new_provider
    }

    it 'does not make a copy of the course' do
      expect { service.execute(new_provider) }
        .not_to(change { new_provider.reload.courses.count })
    end

    it 'does not make a copy of the enrichments' do
      expect { service.execute(new_provider) }
        .not_to(change { new_course.reload.enrichments.count })
    end
  end

  context 'the original course has sites' do
    let(:site) { create :site, provider: provider }
    let!(:new_site) { create :site, provider: new_provider, code: site.code }
    let!(:site_status) {
      create :site_status,
             :with_no_vacancies,
             course: course,
             site: site
    }

    before do
      described_class.new(course: course).execute(new_provider)
    end

    describe 'the new course' do
      subject { new_course }

      its(:ucas_status) { should eq :new }
      its(:open_for_applications?) { should be_falsey }
    end

    describe "the new course's list of sites" do
      subject { new_course.sites }

      its(:length) { should eq 1 }
    end

    describe 'the new site' do
      subject { new_course.sites.first }

      it { should eq new_site }
      its(:code) { should eq site.code }
    end

    describe "the new site's status" do
      subject { new_course.site_statuses.first }

      it { should be_full_time_vacancies }
      it { should be_status_new_status }
      its(:applications_accepted_from) { should eq new_recruitment_cycle.application_start_date }
    end
  end
end
