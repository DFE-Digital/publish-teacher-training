# frozen_string_literal: true

require 'rails_helper'

module Find
  describe TrackClick do
    before do
      allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)
    end

    let(:request_double) do
      instance_double(ActionDispatch::Request,
                      uuid: SecureRandom.uuid,
                      user_agent: 'Chrome',
                      method: :get,
                      original_fullpath: '/path',
                      query_string: nil,
                      referer: nil,
                      headers: { 'X-REAL-IP' => '1.2.3.4' })
    end

    subject(:tracker) { described_class.new(request: request_double) }

    describe '.track_click' do
      before { tracker.track_click(utm_content: 'become_a_teacher', url: 'https://getintoteaching.education.gov.uk/steps-to-become-a-teacher') }

      it 'enqueues a track_click event' do
        expect(:track_click).to have_been_enqueued_as_analytics_events
      end
    end
  end
end
