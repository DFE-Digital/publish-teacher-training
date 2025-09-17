# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::CopyToProviderService do
  let(:accrediting_provider) { create(:provider, :accredited_provider, recruitment_cycle:) }
  let(:provider) { create(:provider, courses: [course], recruitment_cycle:) }
  let(:published_course_enrichment) { build(:course_enrichment, :published) }
  let(:maths) { create(:secondary_subject, :mathematics) }
  let(:course) do
    create(:course,
           enrichments: [published_course_enrichment],
           accrediting_provider:,
           subjects: [maths], level: "secondary")
  end
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:new_recruitment_cycle) { create(:recruitment_cycle, :next) }
  let(:new_provider) do
    create(:provider,
           provider_code: provider.provider_code,
           recruitment_cycle: new_recruitment_cycle)
  end
  let(:new_course) do
    new_provider.reload.courses.find_by(course_code: course.course_code)
  end

  let(:mocked_sites_copy_to_course_service) { double(call: nil) }
  let(:mocked_enrichments_copy_to_course_service) { double(execute: nil) }
  let(:service) do
    described_class.new(
      sites_copy_to_course: mocked_sites_copy_to_course_service,
      enrichments_copy_to_course: mocked_enrichments_copy_to_course_service,
      force:,
    )
  end

  let(:force) { false }

  it "makes a copy of the course in the new provider" do
    service.execute(course:, new_provider:)

    expect(new_course).not_to be_nil
    expect(new_course.accredited_provider_code).to eq course.accredited_provider_code
    expect(new_course.subjects.count).to eq course.subjects.count
    expect(new_course.subjects.first.id).to eq course.subjects.first.id
    expect(new_course.subjects.first.type).to eq course.subjects.first.type
    expect(new_course.subjects.first.subject_code).to eq course.subjects.first.subject_code
    expect(new_course.subjects.first.subject_name).to eq course.subjects.first.subject_name
    expect(new_course.content_status).to eq :draft
    expect(new_course.ucas_status).to eq :new
    expect(new_course.open_for_applications?).to be_falsey
    expect(new_course.can_sponsor_skilled_worker_visa).to eq course.can_sponsor_skilled_worker_visa
    expect(new_course.can_sponsor_student_visa).to eq course.can_sponsor_student_visa
  end

  it "sets the visa_sponsorship_application_deadline_at to nil" do
    course.can_sponsor_student_visa = true
    course.visa_sponsorship_application_deadline_at = 1.week.before(Find::CycleTimetable.find_closes)
    course.save!(validate: false)

    service.execute(course:, new_provider:)

    expect(new_course.visa_sponsorship_application_deadline_at).to be_nil
  end

  it "adds the copied course to @courses_copied" do
    service.execute(course:, new_provider:)

    expect(service.courses_copied.map(&:course_code)).to include(course.course_code)
  end

  context "applications open from date" do
    it "updates the applications_open_from and start date attributes" do
      service.execute(course:, new_provider:)
      expect(new_course.start_date).to eq course.start_date + 1.year
      expect(new_course.applications_open_from).to eq course.applications_open_from + 1.year
    end

    context "when the original course's date is before the next cycle's start date" do
      before do
        course.applications_open_from = Date.new(provider.recruitment_cycle.year.to_i - 1, 10, 1)
      end

      it "sets the new course's applications open from date correctly" do
        service.execute(course:, new_provider:)

        expect(new_course.applications_open_from).to eq(Find::CycleTimetable.apply_reopens.to_date)
      end
    end

    context "when the original course's date is at the beginning of the cycle" do
      let(:new_recruitment_cycle) { create(:recruitment_cycle, :next, application_start_date: "2023-09-01") }

      before do
        course.applications_open_from = provider.recruitment_cycle.application_start_date
      end

      it "sets the new course's applications open from date correctly" do
        service.execute(course:, new_provider:)

        expect(new_course.applications_open_from).to eq(Find::CycleTimetable.apply_reopens.to_date)
      end
    end
  end

  context "when the original course is open" do
    before do
      course.update(application_status: "open")
    end

    it "sets the new course's application_status to closed" do
      service.execute(course:, new_provider:)

      expect(new_course.application_status).to eq("closed")
    end
  end

  it "leaves the existing course alone" do
    service.execute(course:, new_provider:)

    expect(provider.reload.courses).to eq [course]
  end

  it "doesn't copy enrichments when they do not exist" do
    service.execute(course:, new_provider:)

    expect(mocked_enrichments_copy_to_course_service).not_to have_received(:execute).with(
      enrichment: nil,
    )
  end

  it "saves without doing validations" do
    course_dup = instance_spy(Course, recruitment_cycle:)
    allow(course).to receive(:dup).and_return(course_dup)

    service.execute(course:, new_provider:)

    expect(course_dup).to have_received(:save!).with(validate: false)
  end

  context "when a published enrichment exists" do
    let!(:old_published_enrichment) do
      create(:course_enrichment, :published, last_published_timestamp_utc: 10.days.ago, course:)
    end
    let!(:published_enrichment) do
      create(:course_enrichment, :published, course:)
    end

    it "copies the latest published enrichment" do
      service.execute(course:, new_provider:)

      expect(mocked_enrichments_copy_to_course_service).to have_received(:execute).with(
        enrichment: published_enrichment, new_course:,
      )
    end
  end

  context "course has a published and a draft enrichment" do
    it "copies the latest enrichment" do
      draft_enrichment = create(:course_enrichment, status: :draft, course:)

      course.enrichments.reload

      service.execute(course:, new_provider:)

      expect(mocked_enrichments_copy_to_course_service).to have_received(:execute).with(
        enrichment: draft_enrichment,
        new_course:,
      )
    end
  end

  context "the course already exists in the new provider" do
    let!(:new_course) do
      create(:course,
             course_code: course.course_code,
             provider: new_provider)
    end

    it "returns nil" do
      expect(service.execute(course:, new_provider:)).to be_nil
    end

    it "does not make a copy of the course" do
      service.execute(course:, new_provider:)

      expect(mocked_sites_copy_to_course_service).not_to have_received(:call)
    end

    it "does not make a copy of the enrichments" do
      service.execute(course:, new_provider:)

      expect(mocked_enrichments_copy_to_course_service).not_to have_received(:execute)
    end

    it "adds the uncopied course to @courses_not_copied" do
      service.execute(course:, new_provider:)

      expect(service.courses_not_copied).to include(course)
    end
  end

  context "the course has been deleted in the new provider" do
    let!(:new_course) do
      create(:course,
             :deleted,
             course_code: course.course_code,
             provider: new_provider)
    end

    it "returns nil" do
      expect(service.execute(course:, new_provider:)).to be_nil
    end

    it "does not make a copy of the course" do
      service.execute(course:, new_provider:)

      expect(mocked_sites_copy_to_course_service).not_to have_received(:call)
    end

    it "does not make a copy of the enrichments" do
      service.execute(course:, new_provider:)

      expect(mocked_enrichments_copy_to_course_service).not_to have_received(:execute)
    end
  end

  context "the original course has schools" do
    let(:site) { create(:site, :school, provider:) }
    let!(:new_site) { create(:site, :school, provider: new_provider, code: site.code) }
    let!(:site_status) do
      create(:site_status,
             :no_vacancies,
             course:,
             site:)
    end

    before do
      described_class.new(
        sites_copy_to_course: mocked_sites_copy_to_course_service,
        enrichments_copy_to_course: mocked_enrichments_copy_to_course_service,
        force:,
      ).execute(course:, new_provider:)
    end

    describe "the new course" do
      subject { new_course }

      its(:ucas_status) { is_expected.to eq :new }
      its(:open_for_applications?) { is_expected.to be_falsey }
    end

    it "copies over the course's sites" do
      expect(mocked_sites_copy_to_course_service).to have_received(:call).with(new_site:, new_course:)
    end
  end

  context "the original course has study sites" do
    let(:site) { create(:site, :study_site, provider:) }
    let!(:new_site) { create(:site, :study_site, provider: new_provider, code: site.code) }
    let!(:study_site_placement) { create(:study_site_placement, course:, site:) }

    before do
      described_class.new(
        sites_copy_to_course: mocked_sites_copy_to_course_service,
        enrichments_copy_to_course: mocked_enrichments_copy_to_course_service,
        force:,
      ).execute(course:, new_provider:)
    end

    describe "the new course" do
      subject { new_course }

      its(:open_for_applications?) { is_expected.to be_falsey }
    end

    it "copies over the course's study sites" do
      expect(mocked_sites_copy_to_course_service).to have_received(:call).with(new_site:, new_course:)
    end
  end

  context "when the course is not rollable" do
    let(:site) { create(:site, provider:) }
    let!(:new_site) { create(:site, provider: new_provider, code: site.code) }
    let(:force) { true }

    before do
      allow(course).to receive(:rollable?).and_return(false)

      described_class.new(
        sites_copy_to_course: mocked_sites_copy_to_course_service,
        enrichments_copy_to_course: mocked_enrichments_copy_to_course_service,
        force:,
      ).execute(course:, new_provider:)
    end

    it "still copies the course to the provider" do
      new_course = new_provider.reload.courses.first
      expect(new_course.course_code).to eq(course.course_code)
      expect(new_provider.courses.count).to eq(1)
    end
  end
end
