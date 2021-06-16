require "rails_helper"

describe Enrichments::CopyToCourseService do
  let(:service) { described_class.new }
  let(:course) { create(:course) }
  let(:new_course) { create(:course) }
  let(:published_enrichment) do
    create :course_enrichment, :published, course: course
  end

  before { service.execute(enrichment: published_enrichment, new_course: new_course) }

  subject { new_course.enrichments }

  its(:length) { is_expected.to eq 1 }

  describe "the new course" do
    subject { new_course }

    its(:content_status) { is_expected.to eq :rolled_over }
  end

  describe "the copied enrichment" do
    subject { new_course.enrichments.first }

    its(:about_course) { is_expected.to eq published_enrichment.about_course }
    its(:last_published_timestamp_utc) { is_expected.to be_nil }
    it { is_expected.to be_rolled_over }
  end
end
