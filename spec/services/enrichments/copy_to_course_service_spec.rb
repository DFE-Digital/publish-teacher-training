# frozen_string_literal: true

require "rails_helper"

describe Enrichments::CopyToCourseService do
  subject { new_course.enrichments }

  let(:service) { described_class.new }
  let(:course) { create(:course) }
  let(:new_course) { create(:course) }
  let(:published_enrichment) do
    create(:course_enrichment, :published, course:)
  end

  before { service.execute(enrichment: published_enrichment, new_course:) }

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
