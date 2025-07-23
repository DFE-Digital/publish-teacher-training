# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::Analytics::SavedCourseEvent do
  subject do
    described_class.new(attributes.merge(request:))
  end

  let(:request) { ActionDispatch::Request.new({}) }

  let(:attributes) { {} }

  it_behaves_like "an analytics event"

  describe "#event_name" do
    it "returns :saved_course" do
      expect(subject.event_name).to eq(:saved_course)
    end
  end

  describe "#event_data" do
    let(:attributes) do
      {
        candidate_id: 1360,
        course_id: 2,
      }
    end

    context "when a destroy event is called" do
      it "returns a hash with all the event information" do
        allow(request).to receive(:referer).and_return("/results")

        frozen_time = Time.utc(2023, 1, 1, 12, 0, 0)
        allow(Time).to receive(:now).and_return(frozen_time)

        expect(subject.event_data).to eq(
          namespace: "find",
          candidate_id: 1360,
          course_id: 2,
          timestamp: frozen_time,
          referer: "/results",
        )
      end
    end
  end
end
