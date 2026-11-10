# frozen_string_literal: true

require "rails_helper"

describe Enrichments::CopyToCourseService do
  let(:service) { described_class.new }
  let(:course) { create(:course) }
  let(:new_course) { create(:course) }
  let(:published_enrichment) do
    create(:course_enrichment, :published, course:)
  end

  describe "copying a valid enrichment" do
    subject { new_course.enrichments }

    before do
      service.execute(enrichment: published_enrichment, new_course:)
      new_course.enrichments.reload
    end

    its(:length) { is_expected.to eq 1 }

    describe "the new course" do
      subject { new_course }

      its(:content_status) { is_expected.to eq :rolled_over }
    end

    describe "the copied enrichment" do
      subject { new_course.enrichments.first }

      its(:theoretical_training_activities) { is_expected.to eq published_enrichment.theoretical_training_activities }
      its(:last_published_timestamp_utc) { is_expected.to be_nil }
      it { is_expected.to be_rolled_over }
    end

    it "records the rollover audit against the destination course" do
      copied_enrichment = new_course.enrichments.first
      audit = Audited::Audit.find_by!(
        auditable: copied_enrichment,
        action: "create",
      )

      expect(audit.associated).to eq(new_course)
      expect(audit.audited_changes["status"]).to eq(CourseEnrichment.statuses[:rolled_over])
        .or(eq("rolled_over"))
    end
  end

  describe "copying an invalid enrichment" do
    let(:published_enrichment) do
      enrichment = build(
        :course_enrichment,
        :published,
        course:,
        personal_qualities: ("word " * 150).strip,
      )
      enrichment.save!(validate: false)
      enrichment
    end

    it "raises so rollover can roll back" do
      expect {
        service.execute(enrichment: published_enrichment, new_course:)
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(new_course.enrichments.reload).to be_empty
    end
  end
end
