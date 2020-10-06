require "rails_helper"

describe RolloverReportingService do
  let(:published_running_site) { create(:site_status, :published, :running) }
  let(:provider) { create(:provider, :next_recruitment_cycle) }
  let(:published_course) { create(:course, provider: provider, site_statuses: [published_running_site]) }
  let(:new_published_course) { create(:course, age: provider.recruitment_cycle.created_at + 28.hours, provider: provider, site_statuses: [published_running_site]) }
  let(:deleted_course) { create(:course, :deleted, provider: provider) }
  let(:course_in_draft) { create(:course, age: provider.recruitment_cycle.created_at + 25.hours, provider: provider) }
  let(:second_course_in_draft) { create(:course, age: provider.recruitment_cycle.created_at + 26.hours, provider: provider) }

  describe ".call" do
    subject(:result) { described_class.call }

    context "number of published courses after rollover" do
      before do
        provider
        published_course
      end

      it "returns the correct published courses" do
        expect(result[:total][:published_courses]).to eq 1
      end
    end

    context "number of new published courses after rollover" do
      before do
        provider
        new_published_course
      end

      it "returns the correct newly published courses" do
        expect(result[:total][:new_courses_published]).to eq 1
      end
    end

    context "number of deleted courses after rollover" do
      before do
        provider
        deleted_course
      end

      it "returns the correct deleted courses" do
        deleted_course
        expect(result[:total][:deleted_courses]).to eq 1
      end
    end

    context "number of courses after rollover that are in draft" do
      before do
        provider
        course_in_draft
        second_course_in_draft
        new_published_course
      end

      it "returns the correct courses in draft" do
        expect(result[:total][:existing_courses_in_draft]).to eq 2
      end
    end

    context "number of courses after rollover that are in review" do
      before do
        provider
        course_in_draft
        new_published_course
        deleted_course
        published_course
      end

      it "it returns the correct courses in review" do
        expect(result[:total][:existing_courses_in_review]).to eq 1
      end
    end

    context "if there is no next recruitment cycle" do
      it "returns an empty object" do
        expect(result).to eq({
                                total: {
                                  published_courses: 0,
                                  new_courses_published: 0,
                                  deleted_courses: 0,
                                  existing_courses_in_draft: 0,
                                  existing_courses_in_review: 0,
                                },
                              })
      end
    end
  end
end
