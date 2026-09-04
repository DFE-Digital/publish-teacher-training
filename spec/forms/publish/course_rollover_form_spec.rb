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

    before do
      find_or_create(:recruitment_cycle, :next).update(available_in_publish_from: 1.day.ago)
    end

    describe "draft course" do
      let(:course) { create(:course, enrichments: [draft_enrichment]) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "rolled over course" do
      let(:course) { create(:course, enrichments: [rolled_over_enrichment]) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "empty course" do
      let(:course) { create(:course, enrichments: []) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "published course" do
      let(:course) { create(:course, enrichments: [published_enrichment]) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "legacy subsequent draft course" do
      let(:course) { create(:course, enrichments: [unpublished_changes_enrichment]) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "withdrawn course" do
      let(:course) { create(:course, enrichments: [withdrawn_enrichment]) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "course that has already been rolled over" do
      let(:course) { create(:course, enrichments: [published_enrichment]) }

      before do
        create(
          :course,
          course_code: course.course_code,
          provider: create(:provider, recruitment_cycle: RecruitmentCycle.next, provider_code: course.provider.provider_code),
        )
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:course_is_rollable]).to include "This course cannot be rolled over into the next recruitment cycle."
      end
    end

    describe "course in a cycle that is not open for rollover" do
      let(:course) { create(:course, enrichments: [published_enrichment]) }

      before do
        RecruitmentCycle.next.update(available_in_publish_from: 1.day.from_now)
      end

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end
  end
end
