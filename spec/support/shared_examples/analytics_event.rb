# frozen_string_literal: true

RSpec.shared_examples 'an analytics event' do
  before do
    allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)
  end

  describe '#send_event' do
    it 'enqueues an analytics event' do
      subject.send_event
      expect(subject.event_name).to have_been_enqueued_as_analytics_events
    end
  end
end
