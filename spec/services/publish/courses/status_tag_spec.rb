# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::StatusTag do
  # Rows come from the query, so a course carries the computed content_status
  # column the token reads.
  def row_for(course)
    Publish::Courses::Query.call(provider: course.provider.reload).detect { |row| row.id == course.id }
  end

  describe ".token" do
    let(:provider) { create(:provider, :accredited_provider) }

    context "in the current recruitment cycle" do
      it "is :draft for a course with no enrichment" do
        course = create(:course, provider:)

        expect(described_class.token(row_for(course))).to eq(:draft)
      end

      it "is :draft for a course with only a draft enrichment" do
        course = create(:course, :draft_enrichment, provider:)

        expect(described_class.token(row_for(course))).to eq(:draft)
      end

      it "is :open for a published course accepting applications" do
        course = create(:course, :published, provider:, application_status: :open)

        expect(described_class.token(row_for(course))).to eq(:open)
      end

      it "is :closed for a published course not accepting applications" do
        course = create(:course, :published, provider:, application_status: :closed)

        expect(described_class.token(row_for(course))).to eq(:closed)
      end

      it "treats unpublished changes as the same token as published" do
        course = create(:course, provider:, application_status: :open,
                                 enrichments: [build(:course_enrichment, :published), build(:course_enrichment, :initial_draft)])

        expect(described_class.token(row_for(course))).to eq(:open)
      end

      it "is :rolled_over for a rolled over course" do
        course = create(:course, provider:, enrichments: [build(:course_enrichment, :rolled_over)])

        expect(described_class.token(row_for(course))).to eq(:rolled_over)
      end

      it "is :withdrawn for a withdrawn course" do
        course = create(:course, :withdrawn, provider:)

        expect(described_class.token(row_for(course))).to eq(:withdrawn)
      end
    end

    context "in a future recruitment cycle" do
      let(:provider) { create(:provider, :accredited_provider, :next_recruitment_cycle) }

      it "is :scheduled for a published course, whatever its application status" do
        course = create(:course, :published, provider:, application_status: :closed)

        expect(described_class.token(row_for(course))).to eq(:scheduled)
      end

      it "is still :draft for a draft course" do
        course = create(:course, :draft_enrichment, provider:)

        expect(described_class.token(row_for(course))).to eq(:draft)
      end
    end
  end
end
