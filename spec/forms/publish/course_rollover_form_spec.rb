# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseRolloverForm, type: :model do
    let(:draft_enrichment) { build(:course_enrichment, :initial_draft) }
    let(:rolled_over_enrichment) { build(:course_enrichment, :rolled_over) }
    let(:published_enrichment) { build(:course_enrichment, :published) }

    subject { described_class.new(course) }

    describe "draft course" do
      let(:course) { build(:course, enrichments: [draft_enrichment]) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "rolled over course" do
      let(:course) { build(:course, enrichments: [rolled_over_enrichment]) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "empty course" do
      let(:course) { build(:course, enrichments: []) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "published course" do
      let(:course) { build(:course, enrichments: [published_enrichment]) }

      it "is valid" do
        expect(subject).not_to be_valid
      end
    end
  end
end
