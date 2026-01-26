# frozen_string_literal: true

RSpec.shared_examples "an analytics event" do
  before do
    allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)
  end

  describe "#send_event" do
    it "enqueues an analytics event" do
      subject.send_event
      expect(subject.event_name).to have_been_enqueued_as_analytics_events
    end

    it "assigns the Current user from the session" do
      sessionable = build_stubbed(:candidate)
      Current.session = build_stubbed(:session, sessionable:)

      expect(subject.send_event.arguments.dig(0, 0, "user_id")).to eq(sessionable.id)
    end
  end
end
