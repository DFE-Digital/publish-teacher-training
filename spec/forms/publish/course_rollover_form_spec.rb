# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseRolloverForm, type: :model do
    let(:draft_enrichment) { build(:course_enrichment, :initial_draft) }
    let(:rolled_over_enrichment) { build(:course_enrichment, :rolled_over) }
    let(:published_enrichment) { build(:course_enrichment, :published) }
    let(:withdrawn_enrichment) { build(:course_enrichment, :withdrawn) }
    let(:unpublished_changes_enrichment) { build(:course_enrichment, :subsequent_draft) }

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

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    describe "unpublished changes course" do
      let(:course) { build(:course, enrichments: [unpublished_changes_enrichment]) }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    describe "withdrawn course" do
      let(:course) { build(:course, enrichments: [withdrawn_enrichment]) }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:course_is_rollable]).to include "Course must have draft, empty or rolled over status."
      end
    end
  end
end
