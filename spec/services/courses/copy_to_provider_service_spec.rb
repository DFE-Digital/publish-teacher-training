require "rails_helper"

RSpec.describe Courses::CopyToProviderService do
  let(:accrediting_provider) { create :provider, :accredited_body }
  let(:provider) { create :provider, courses: [course] }
  let(:published_course_enrichment) { build :course_enrichment, :published }
  let(:maths) { create :secondary_subject, :mathematics }
  let(:course) {
    build :course,
          enrichments: [published_course_enrichment],
          accrediting_provider: accrediting_provider,
          subjects: [maths], level: "secondary"
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
      enrichments_copy_to_course: mocked_enrichments_copy_to_course_service,
    )
  end

  it "makes a copy of the course in the new provider" do
    service.execute(course: course, new_provider: new_provider, force: false)

    expect(new_course).not_to be_nil
    expect(new_course.accredited_body_code).to eq course.accredited_body_code
    expect(new_course.subjects.count).to eq course.subjects.count
    expect(new_course.subjects.first.id).to eq course.subjects.first.id
    expect(new_course.subjects.first.type).to eq course.subjects.first.type
    expect(new_course.subjects.first.subject_code).to eq course.subjects.first.subject_code
    expect(new_course.subjects.first.subject_name).to eq course.subjects.first.subject_name
    expect(new_course.content_status).to eq :rolled_over
    expect(new_course.ucas_status).to eq :new
    expect(new_course.open_for_applications?).to be_falsey
  end

  it "updates the applications_open_from and start date attributes" do
    service.execute(course: course, new_provider: new_provider, force: false)
    expect(new_course.start_date).to eq course.start_date + 1.year
    expect(new_course.applications_open_from).to eq course.applications_open_from + 1.year
  end

  it "leaves the existing course alone" do
    service.execute(course: course, new_provider: new_provider, force: false)

    expect(provider.reload.courses).to eq [course]
  end

  it "doesn't copy enrichments when they do not exist" do
    service.execute(course: course, new_provider: new_provider, force: false)

    expect(mocked_enrichments_copy_to_course_service).to_not have_received(:execute).with(
      enrichment: nil,
    )
  end

  it "saves without doing validations" do
    course_dup = instance_spy(Course, recruitment_cycle: recruitment_cycle)
    allow(course).to receive(:dup).and_return(course_dup)

    service.execute(course: course, new_provider: new_provider, force: false)

    expect(course_dup).to have_received(:save!).with(validate: false)
  end

  context "when a published enrichment exists" do
    let!(:old_published_enrichment) do
      create :course_enrichment, :published, last_published_timestamp_utc: 10.days.ago, course: course
    end
    let!(:published_enrichment) do
      create :course_enrichment, :published, course: course
    end

    it "copies the latest published enrichment" do
      service.execute(course: course, new_provider: new_provider, force: false)

      expect(mocked_enrichments_copy_to_course_service).to have_received(:execute).with(
        enrichment: published_enrichment, new_course: new_course,
      )
    end
  end

  context "course has a published and a draft enrichment" do
    let!(:published_enrichment) do
      create :course_enrichment, :published, course: course
    end
    let!(:draft_enrichment) do
      create :course_enrichment, course: course
    end

    it "copies the draft enrichment" do
      service.execute(course: course, new_provider: new_provider, force: false)

      expect(mocked_enrichments_copy_to_course_service).to have_received(:execute).with(
        enrichment: draft_enrichment, new_course: new_course,
      )
    end
  end

  context "the course already exists in the new provider" do
    let!(:new_course) {
      create :course,
             course_code: course.course_code,
             provider: new_provider
    }

    it "returns nil" do
      expect(service.execute(course: course, new_provider: new_provider, force: false)).to be_nil
    end

    it "does not make a copy of the course" do
      service.execute(course: course, new_provider: new_provider, force: false)

      expect(mocked_sites_copy_to_course_service).to_not have_received(:execute)
    end

    it "does not make a copy of the enrichments" do
      service.execute(course: course, new_provider: new_provider, force: false)

      expect(mocked_enrichments_copy_to_course_service).to_not have_received(:execute)
    end
  end

  context "the course has been deleted in the new provider" do
    let!(:new_course) do
      create :course,
             :deleted,
             course_code: course.course_code,
             provider: new_provider
    end

    it "returns nil" do
      expect(service.execute(course: course, new_provider: new_provider, force: false)).to be_nil
    end

    it "does not make a copy of the course" do
      service.execute(course: course, new_provider: new_provider, force: false)

      expect(mocked_sites_copy_to_course_service).to_not have_received(:execute)
    end

    it "does not make a copy of the enrichments" do
      service.execute(course: course, new_provider: new_provider, force: false)

      expect(mocked_enrichments_copy_to_course_service).to_not have_received(:execute)
    end
  end

  context "the original course has sites" do
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
        enrichments_copy_to_course: mocked_enrichments_copy_to_course_service,
      ).execute(course: course, new_provider: new_provider, force: false)
    end

    describe "the new course" do
      subject { new_course }

      its(:ucas_status) { is_expected.to eq :new }
      its(:open_for_applications?) { is_expected.to be_falsey }
    end

    it "copies over the course's sites" do
      expect(mocked_sites_copy_to_course_service).to have_received(:execute).with(new_site: new_site, new_course: new_course)
    end
  end

  context "when the course is not rollable" do
    let(:force) { false }
    let(:site) { create :site, provider: provider }
    let!(:new_site) { create :site, provider: new_provider, code: site.code }

    before do
      allow(course).to receive(:rollable?).and_return(false)

      described_class.new(
        sites_copy_to_course: mocked_sites_copy_to_course_service,
        enrichments_copy_to_course: mocked_enrichments_copy_to_course_service,
      ).execute(course: course, new_provider: new_provider, force: force)
    end

    context "when the force is used" do
      let(:force) { true }

      it "still copies the course to the provider" do
        new_course = new_provider.courses.first
        expect(new_course.course_code).to eq(course.course_code)
        expect(new_provider.courses.count).to eq(1)
      end
    end

    context "when the force is false" do
      let(:force) { false }

      it "does not copies the course to the provider" do
        new_course = new_provider.courses.first
        expect(new_course).to be_nil
        expect(new_provider.courses.count).to eq(0)
      end
    end
  end
end
