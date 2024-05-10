# frozen_string_literal: true

require 'rails_helper'

module Find
  describe ResultsTracking do
    let(:request_double) do
      instance_double(ActionDispatch::Request,
                      uuid: SecureRandom.uuid,
                      user_agent: 'Chrome',
                      method: :get,
                      original_fullpath: '/path',
                      query_string: nil,
                      referer: nil,
                      remote_ip: '1.2.3.4')
    end

    subject(:tracker) { described_class.new(request: request_double) }

    describe '.track_search_results' do
      before { tracker.track_search_results(number_of_results: 1, course_codes: ['123']) }

      it 'enqueues a track_search_results event' do
        expect(:search_results).to have_been_enqueued_as_analytics_events
      end
    end
  end
end
