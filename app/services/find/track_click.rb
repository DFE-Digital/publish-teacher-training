# frozen_string_literal: true

module Find
  class TrackClick
    attr_reader :request

    def initialize(request:)
      @request = request
    end

    def track_click(utm_content:, url:)
      event = DfE::Analytics::Event.new
                                   .with_type(:track_click)
                                   .with_request_details(request)
                                   .with_data(utm_content:, url:)

      DfE::Analytics::SendEvents.do([event])
    end
  end
end
