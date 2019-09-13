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

  let(:mocked_sites_copy_to_course_service) { double(execute: nil) }
  let(:mocked_enrichments_copy_to_course_service) { double(execute: nil) }
  let(:service) do
    described_class.new(
      sites_copy_to_course: mocked_sites_copy_to_course_service,
      enrichments_copy_to_course: mocked_enrichments_copy_to_course_service
    )
  end

  it 'makes a copy of the course in the new provider' do
    service.execute(course: course, new_provider: new_provider)

    expect(new_course).not_to be_nil
    expect(new_course.accrediting_provider_code)
      .to eq course.accrediting_provider_code
    expect(new_course.subjects).to eq course.subjects
    expect(new_course.content_status).to eq :rolled_over
    expect(new_course.ucas_status).to eq :new
    expect(new_course.open_for_applications?).to be_falsey
  end

  it 'leaves the existing course alone' do
    service.execute(course: course, new_provider: new_provider)

    expect(provider.reload.courses).to eq [course]
  end

  it "doesn't copy enrichments when they do not exist" do
    service.execute(course: course, new_provider: new_provider)

    expect(mocked_enrichments_copy_to_course_service).to_not have_received(:execute)
  end

  context 'when a published enrichment exists' do
    let!(:old_published_enrichment) do
      create :course_enrichment, :published, last_published_timestamp_utc: 10.days.ago, course: course
    end
    let!(:published_enrichment) do
      create :course_enrichment, :published, course: course
    end

    it 'copies the latest published enrichment' do
      service.execute(course: course, new_provider: new_provider)

      expect(mocked_enrichments_copy_to_course_service).to have_received(:execute).with(
        enrichment: published_enrichment, new_course: new_course
      )
    end
  end

  context 'course has a published and a draft enrichment' do
    let!(:published_enrichment) do
      create :course_enrichment, :published, course: course
    end
    let!(:draft_enrichment) do
      create :course_enrichment, course: course
    end

    it 'copies the draft enrichment' do
      service.execute(course: course, new_provider: new_provider)

      expect(mocked_enrichments_copy_to_course_service).to have_received(:execute).with(
        enrichment: draft_enrichment, new_course: new_course
      )
    end
  end

  context 'the course already exists in the new provider' do
    let!(:new_course) {
      create :course,
             course_code: course.course_code,
             provider: new_provider
    }

    it 'does not make a copy of the course' do
      expect(mocked_sites_copy_to_course_service).to_not have_received(:execute)
    end

    it 'does not make a copy of the enrichments' do
      expect(mocked_enrichments_copy_to_course_service).to_not have_received(:execute)
    end
  end

  context 'the course has been deleted in the new provider' do
    let!(:new_course) do
      create :course,
             :deleted,
             course_code: course.course_code,
             provider: new_provider
    end

    it 'returns nil' do
      expect(service.execute(course: course, new_provider: new_provider)).to be_nil
    end

    it 'does not make a copy of the course' do
      service.execute(course: course, new_provider: new_provider)

      expect(mocked_sites_copy_to_course_service).to_not have_received(:execute)
    end

    it 'does not make a copy of the enrichments' do
      service.execute(course: course, new_provider: new_provider)

      expect(mocked_enrichments_copy_to_course_service).to_not have_received(:execute)
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
      described_class.new(
        sites_copy_to_course: mocked_sites_copy_to_course_service,
        enrichments_copy_to_course: mocked_enrichments_copy_to_course_service
      ).execute(course: course, new_provider: new_provider)
    end

    describe 'the new course' do
      subject { new_course }

      its(:ucas_status) { should eq :new }
      its(:open_for_applications?) { should be_falsey }
    end

    it "copies over the course's sites" do
      expect(mocked_sites_copy_to_course_service).to have_received(:execute).with(new_site: new_site, new_course: new_course)
    end
  end
end
