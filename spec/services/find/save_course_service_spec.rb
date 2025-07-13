# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::SaveCourseService do
  describe ".call" do
    let(:candidate) { create(:candidate) }
    let(:course) { create(:course) }

    context "when the course is saved successfully" do
      it "returns the saved course" do
        result = described_class.call(candidate: candidate, course: course)
        expect(result).to be_a(SavedCourse)
        expect(result.course_id).to eq(course.id)
        expect(candidate.saved_courses.exists?(course_id: course.id)).to be(true)
      end
    end

    context "when saving the course fails" do
      before do
        allow(candidate.saved_courses).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordInvalid.new(candidate))
        allow(Sentry).to receive(:capture_exception)
      end

      it "returns nil and reports to Sentry" do
        result = described_class.call(candidate: candidate, course: course)
        expect(result).to be_nil
        expect(Sentry).to have_received(:capture_exception).once
      end
    end
  end
end
