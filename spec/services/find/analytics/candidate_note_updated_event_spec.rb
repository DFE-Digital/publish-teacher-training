# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::Analytics::CandidateNoteUpdatedEvent do
  subject do
    described_class.new(attributes.merge(request:))
  end

  let(:request) { ActionDispatch::Request.new({}) }

  let(:attributes) { {} }

  it_behaves_like "an analytics event"

  describe "#event_name" do
    it "returns :candidate_note_updated" do
      expect(subject.event_name).to eq(:candidate_note_updated)
    end
  end

  describe "#namespace" do
    it "returns 'find'" do
      expect(subject.namespace).to eq("find")
    end
  end

  describe "#event_data" do
    let(:attributes) do
      {
        course_id: 2,
        saved_course_id: 10,
        note_before_edit: "This is my old note",
        note_after_edit: "This is my updated note",
      }
    end

    it "returns a hash with all the event information" do
      frozen_time = Time.utc(2023, 1, 1, 12, 0, 0)
      allow(Time).to receive(:now).and_return(frozen_time)

      expect(subject.event_data).to eq(
        data: {
          course_id: 2,
          saved_course_id: 10,
          note_before_edit: "This is my old note",
          note_after_edit: "This is my updated note",
          timestamp: frozen_time,
        },
      )
    end
  end
end
