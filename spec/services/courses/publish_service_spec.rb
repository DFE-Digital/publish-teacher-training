# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::PublishService do
  subject { described_class.new(course:, user:) }

  let(:uuid) { "b39fe8fe-7cc5-42b8-a06f-d4461b7eb84e" }
  let(:course) { create(:course, :publishable, uuid:) }
  let(:user) { create(:user, :admin) }

  let(:published_new_site)            { create(:site_status, :published, :new_status) }
  let(:published_running_site)        { create(:site_status, :published, :running) }
  let(:published_discontinued_site)   { create(:site_status, :published, :discontinued) }
  let(:published_suspended_site)      { create(:site_status, :published, :suspended) }
  let(:unpublished_new_site)          { create(:site_status, :unpublished, :new_status) }
  let(:unpublished_running_site)      { create(:site_status, :unpublished, :running) }
  let(:unpublished_discontinued_site) { create(:site_status, :unpublished, :discontinued) }
  let(:unpublished_suspended_site)    { create(:site_status, :unpublished, :suspended) }

  describe "publishable course" do
    it "gets published" do
      subject.call
      expect(course.reload).to be_published
    end

    it "returns the course" do
      return_value = subject.call
      expect(course.reload).to eq(return_value)
    end
  end

  describe "publishing during rollover" do
    let(:course) { create(:course, :unpublished, :with_accrediting_provider, :with_gcse_equivalency, uuid:) }
    let(:v1_enrichment) { create(:course_enrichment, :v1, status: "rolled_over", course:) }
    let(:v2_enrichment) { create(:course_enrichment, :v2, status: "draft", course:) }

    before do
      allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(false)
      v1_enrichment
      allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
      v2_enrichment
    end

    it "publishes the draft enrichment" do
      expect(v2_enrichment.reload.status).to eq "draft"
      course_queried = Course.includes(
        :latest_draft_enrichment,
        subjects: [:financial_incentive],
        site_statuses: [:site],
      ).find(course.id)
      described_class.new(course: course_queried, user:).call
      expect(v2_enrichment.reload.status).to eq "published"
    end
  end

  describe "site publishing behavior" do
    context "on an old course with a site" do
      let(:course) { create(:course, :publishable, site_statuses: [published_new_site], age: 5.days.ago) }

      before do
        subject.call
      end

      it "updates course.changed_at" do
        expect(course.changed_at).to be_within(1.second).of(Time.zone.now.utc)
      end
    end

    context "on a course with many sites" do
      let(:course) do
        create(:course, :publishable, site_statuses: [
          published_new_site,
          published_running_site,
          published_discontinued_site,
          published_suspended_site,
          unpublished_new_site,
          unpublished_running_site,
          unpublished_discontinued_site,
          unpublished_suspended_site,
        ], uuid:)
      end

      before do
        subject.call
      end

      it "sets all the sites to the right published/status states" do
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

  describe "unpublishable course" do
    let(:course) { create(:course, uuid:) }

    it "returns false" do
      expect(subject.call).to be(false)
    end
  end

  describe "discarded course" do
    let(:course) { create(:course, :publishable, uuid:, discarded_at: 1.minute.ago) }

    it "undiscards and publishes the course" do
      allow(Course).to receive(:find_by).with({ uuid: uuid }).and_return(course)
      subject.call
      expect(course.reload).to be_published
      expect(course.reload).to be_undiscarded
    end
  end

  describe "publishing failure" do
    it "keeps the course unpublished" do
      allow(Course).to receive(:find_by).with({ uuid: uuid }).and_return(course)
      allow(subject).to receive(:publish_sites).and_raise(AASM::UnknownStateMachineError)
      subject.call
    rescue AASM::UnknownStateMachineError
      expect(course.reload).not_to be_published
    end
  end
end
