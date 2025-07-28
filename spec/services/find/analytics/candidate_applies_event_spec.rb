# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::Analytics::CandidateAppliesEvent do
  subject do
    described_class.new(attributes.merge(request:))
  end

  let(:request) { ActionDispatch::Request.new({}) }

  let(:attributes) { {} }

  it_behaves_like "an analytics event"

  describe "#event_name" do
    it "returns :candidate_applies" do
      expect(subject.event_name).to eq(:candidate_applies)
    end
  end

  describe "#event_data" do
    context "when a non signed in candidate applies for a course that they have not saved" do
      let(:attributes) do
        {
          candidate_id: nil,
          course_id: 2,
        }
      end

      it "returns a hash with all the event information" do
        frozen_time = Time.utc(2023, 1, 1, 12, 0, 0)
        allow(Time).to receive(:now).and_return(frozen_time)

        expect(subject.event_data).to eq(
          namespace: "find",
          candidate_id: nil,
          course_id: 2,
          was_course_saved: false,
          timestamp: frozen_time,
        )
      end
    end

    context "when a signed in candidate applies for a course that they have already saved" do
      let(:candidate) { create(:candidate) }
      let(:frozen_time) { Time.utc(2023, 1, 1, 12, 0, 0) }
      let(:course) { create(:course) }

      let(:attributes) do
        {
          candidate_id: candidate.id,
          course_id: course.id,
        }
      end

      before do
        create(:saved_course, candidate:, course:)
        allow(Time).to receive(:now).and_return(frozen_time)
      end

      it "returns a hash with all the event information" do
        expect(subject.event_data).to eq(
          namespace: "find",
          candidate_id: candidate.id,
          course_id: course.id,
          was_course_saved: true,
          timestamp: frozen_time,
        )
      end
    end

    context "when a signed in candidate applies for a course that they have NOT saved" do
      let(:candidate) { create(:candidate) }
      let(:frozen_time) { Time.utc(2023, 1, 1, 12, 0, 0) }
      let(:course) { create(:course) }

      let(:attributes) do
        {
          candidate_id: candidate.id,
          course_id: course.id,
        }
      end

      before do
        allow(Time).to receive(:now).and_return(frozen_time)
      end

      it "returns a hash with all the event information" do
        expect(subject.event_data).to eq(
          namespace: "find",
          candidate_id: candidate.id,
          course_id: course.id,
          was_course_saved: false,
          timestamp: frozen_time,
        )
      end
    end
  end
end
