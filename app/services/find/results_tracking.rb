# frozen_string_literal: true

module Find
  class ResultsTracking
    attr_reader :request

    def initialize(request:)
      @request = request
    end

    def track_search_results(number_of_results:, course_codes:)
      event = DfE::Analytics::Event.new
                                   .with_type(:search_results)
                                   .with_request_details(request)
                                   .with_data(number_of_results:, course_codes:)

      DfE::Analytics::SendEvents.do([event])
    end
  end
end
