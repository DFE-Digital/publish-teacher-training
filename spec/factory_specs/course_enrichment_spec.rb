require "rails_helper"

describe "Course enrichment factory" do
  context "initial draft enrichment" do
    subject { create(:course_enrichment, :initial_draft) }

    it { should be_valid }
    its(:last_published_timestamp_utc) { should be_nil }
    its(:published?) { should be_falsey }
  end

  context "published enrichment" do
    subject { create(:course_enrichment, :published) }

    it { should be_valid }
    its(:last_published_timestamp_utc) { should_not be_nil }
    its(:published?) { should be_truthy }
  end

  context "subsequent draft enrichment" do
    subject { create(:course_enrichment, :subsequent_draft) }

    it { should be_valid }
    its(:last_published_timestamp_utc) { should_not be_nil }
    its(:published?) { should be_falsey }
  end
end
